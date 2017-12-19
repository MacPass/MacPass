//
//  MPAppDelegate.m
//  MacPass
//
//  Created by Michael Starke on 19.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "MPAppDelegate.h"

#import "MPAutotypeDaemon.h"
#import "MPConstants.h"
#import "MPContextMenuHelper.h"
#import "MPDockTileHelper.h"
#import "MPDocument.h"
#import "MPDocumentController.h"
#import "MPDocumentWindowController.h"
#import "MPLockDaemon.h"
#import "MPPasswordCreatorViewController.h"
#import "MPPluginHost.h"
#import "MPSettingsHelper.h"
#import "MPSettingsWindowController.h"
#import "MPStringLengthValueTransformer.h"
#import "MPPrettyPasswordTransformer.h"
#import "MPTemporaryFileStorageCenter.h"
#import "MPValueTransformerHelper.h"
#import "MPUserNotificationCenterDelegate.h"

#import "NSApplication+MPAdditions.h"

#import "KeePassKit/KeePassKit.h"

#import <Sparkle/Sparkle.h>

NSString *const MPDidChangeStoredKeyFilesSettings = @"com.hicknhack.macpass.MPDidChangeStoredKeyFilesSettings";

@interface MPAppDelegate () {
@private
  MPDockTileHelper *_dockTileHelper;
  MPUserNotificationCenterDelegate *_userNotificationCenterDelegate;
  BOOL _shouldOpenFile; // YES if app was started to open a
}

@property (strong, nonatomic) MPSettingsWindowController *settingsController;
@property (strong, nonatomic) MPPasswordCreatorViewController *passwordCreatorController;

@end

@implementation MPAppDelegate

+ (void)initialize {
  [MPSettingsHelper setupDefaults];
  [MPSettingsHelper migrateDefaults];
  [MPStringLengthValueTransformer registerTransformer];
  [MPPrettyPasswordTransformer registerTransformer];
  [MPValueTransformerHelper registerValueTransformer];
}

- (instancetype)init {
  self = [super init];
  if(self) {
    _userNotificationCenterDelegate = [[MPUserNotificationCenterDelegate alloc] init];
    /* We know that we do not use the variable after instantiation */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    MPDocumentController *documentController = [[MPDocumentController alloc] init];
#pragma clang diagnostic pop
  }
  return self;
}

- (void)dealloc {
  [self unbind:NSStringFromSelector(@selector(isAllowedToStoreKeyFile))];
  [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark Properties
- (void)setIsAllowedToStoreKeyFile:(BOOL)isAllowedToStoreKeyFile {
  if(_isAllowedToStoreKeyFile != isAllowedToStoreKeyFile) {
    _isAllowedToStoreKeyFile = isAllowedToStoreKeyFile;
    /* cleanup on disable */
    if(!self.isAllowedToStoreKeyFile) {
      [self clearRememberdKeyFiles:nil];
    }
    /* Inform anyone that might be interested that we can now no longer/ or can use keyfiles */
    [[NSNotificationCenter defaultCenter] postNotificationName:MPDidChangeStoredKeyFilesSettings object:self];
  }
}

- (void)awakeFromNib {
  _isAllowedToStoreKeyFile = NO;
  /* Update the … at the save menu */
  self.saveMenuItem.menu.delegate = self;
  
  /* We want to inform anyone about the changes to keyFile remembering */
  [self bind:NSStringFromSelector(@selector(isAllowedToStoreKeyFile))
    toObject:NSUserDefaultsController.sharedUserDefaultsController
 withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyRememberKeyFilesForDatabases]
     options:nil];
  
  NSMenu *fileMenu = self.fileNewMenuItem.menu;
  NSInteger insertIndex = [fileMenu indexOfItem:self.fileNewMenuItem]+1;
  NSArray *items = [MPContextMenuHelper contextMenuItemsWithItems:MPContextMenuCreate];
  for(NSMenuItem *item in items.reverseObjectEnumerator) {
    [fileMenu insertItem:item atIndex:insertIndex];
  }
}

#pragma mark -
#pragma mark NSApplicationDelegate

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
  if(!flag) {
    BOOL reopen = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyReopenLastDatabaseOnLaunch];
    BOOL showWelcomeScreen = YES;
    if(reopen) {
      showWelcomeScreen = ![self _reopenLastDocument];
    }
    if(showWelcomeScreen) {
      [self _showWelcomeWindow];
    }
  }
  return YES;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
  return [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyOpenEmptyDatabaseOnLaunch];
}


- (void)applicationWillFinishLaunching:(NSNotification *)notification {
  _shouldOpenFile = NO;
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_applicationDidFinishRestoringWindows:)
                                               name:NSApplicationDidFinishRestoringWindowsNotification
                                             object:nil];
  
  
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
  if([[MPTemporaryFileStorageCenter defaultCenter] hasPendingStorages]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [[MPTemporaryFileStorageCenter defaultCenter] cleanupStorages];
      [sender replyToApplicationShouldTerminate:YES];
    });
    return NSTerminateLater;
  }
  return NSTerminateNow;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
  _shouldOpenFile = YES;
  NSURL *fileURL = [NSURL fileURLWithPath:filename];
  [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:fileURL display:YES completionHandler:^(NSDocument * _Nullable document, BOOL documentWasAlreadyOpen, NSError * _Nullable error){}];
  return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
#if defined(NO_SPARKLE)
  NSLog(@"Sparkle explicitly disabled!!!");
#endif
  /* Daemon instanziieren */
  [MPLockDaemon defaultDaemon];
  [MPAutotypeDaemon defaultDaemon];
  /* Create Plugin Manager */
  [MPPluginHost sharedHost];
#if !defined(DEBUG) && !defined(NO_SPARKLE)
  /* Disable updates if in debug or nosparkle  */
  [SUUpdater sharedUpdater];
#endif
}

#pragma mark -
#pragma mark NSMenuDelegate
- (void)menuNeedsUpdate:(NSMenu *)menu {
  if(menu == self.saveMenuItem.menu) {
    MPDocument *document = [NSDocumentController sharedDocumentController].currentDocument;
    BOOL displayDots = (document.fileURL == nil || !document.compositeKey.hasPasswordOrKeyFile);
    NSString *saveTitle =  displayDots ? NSLocalizedString(@"SAVE_WITH_DOTS", "Save file menu item title when save will prompt for a location to save or ask for a password/key") : NSLocalizedString(@"SAVE", "Save file menu item title when save will just save the file");
    self.saveMenuItem.title = saveTitle;
  }
  if(menu == self.fixAutotypeMenuItem.menu) {
    self.fixAutotypeMenuItem.hidden = !(NSEvent.modifierFlags & NSAlternateKeyMask);
  }
}

#pragma mark -
#pragma mark Actions
- (void)showPreferences:(id)sender {
  if(self.settingsController == nil) {
    self.settingsController = [[MPSettingsWindowController alloc] init];
  }
  [self.settingsController showSettings];
}

- (void)showPasswordCreator:(id)sender {
  if(!self.passwordCreatorWindow) {
    [[NSBundle mainBundle] loadNibNamed:@"PasswordCreatorWindow"owner:self topLevelObjects:nil];
  }
  if(!self.passwordCreatorController) {
    self.passwordCreatorController = [[MPPasswordCreatorViewController alloc] init];
    self.passwordCreatorWindow.contentViewController = self.passwordCreatorController;
  }
  [self.passwordCreatorController reset];
  [self.passwordCreatorWindow makeKeyAndOrderFront:self.passwordCreatorWindow];
}

- (void)createNewDatabase:(id)sender {
  [self.welcomeWindow orderOut:sender];
  [[NSDocumentController sharedDocumentController] newDocument:sender];
}

- (void)openDatabase:(id)sender {
  [self.welcomeWindow orderOut:sender];
  [[NSDocumentController sharedDocumentController] openDocument:sender];
}

- (void)lockAllDocuments {
  for(NSDocument *document in ((NSDocumentController *)[NSDocumentController sharedDocumentController]).documents) {
    for(id windowController in [document.windowControllers reverseObjectEnumerator]) {
      if([windowController respondsToSelector:@selector(lock:)]) {
        [windowController lock:self];
      }
    }
  }
}

- (void)clearRememberdKeyFiles:(id)sender {
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMPSettingsKeyRememeberdKeysForDatabases];
}

- (void)showHelp:(id)sender {
  NSString *urlString = NSBundle.mainBundle.infoDictionary[MPBundleHelpURLKey];
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

- (void)checkForUpdates:(id)sender {
#if defined(DEBUG) || defined(NO_SPARKLE)
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = NSLocalizedString(@"Updates are disabled!", @"Message text for disabled updates alert!");
  alert.informativeText = [NSString stringWithFormat:@"Sparkle updates are disabled for this build of %@!", NSApp.applicationName];
  [alert addButtonWithTitle:NSLocalizedString(@"OK", @"Ok button")];
  [alert runModal];
#else
  [[SUUpdater sharedUpdater] checkForUpdates:sender];
#endif
}

#pragma mark -
#pragma mark Private Helper
- (void)_applicationDidFinishRestoringWindows:(NSNotification *)notification {
  NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
  NSArray *documents = [documentController documents];
  BOOL restoredWindows = [documents count] > 0;
  
  for(NSDocument *document in documents) {
    for(NSWindowController *windowController in [document windowControllers]) {
      [windowController.window.contentView layout];
    }
  }
  
  BOOL reopen = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyReopenLastDatabaseOnLaunch];
  BOOL showWelcomeScreen = !restoredWindows && !_shouldOpenFile;
  if(reopen && !restoredWindows && !_shouldOpenFile) {
    showWelcomeScreen = ![self _reopenLastDocument];
  }
  if(showWelcomeScreen) {
    [self _showWelcomeWindow];
  }
}

- (void)_showWelcomeWindow {
  [self _loadWelcomeWindow];
  [self.welcomeWindow makeKeyAndOrderFront:nil];
}

- (void)_loadWelcomeWindow {
  if(!_welcomeWindow) {
    NSArray *topLevelObject;
    [[NSBundle mainBundle] loadNibNamed:@"WelcomeWindow" owner:self topLevelObjects:&topLevelObject];
  }
}

- (BOOL)_reopenLastDocument {
  NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
  NSArray *documents = [documentController documents];
  if([documents count] > 0) {
    return YES; // The document is already open
  }
  NSArray *recentDocuments = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
  NSURL *documentUrl = nil;
  if([recentDocuments count] > 0) {
    documentUrl = recentDocuments[0];
  }
  else {
    NSString *lastPath = [[NSUserDefaults standardUserDefaults] stringForKey:kMPSettingsKeyLastDatabasePath];
    documentUrl =[NSURL URLWithString:lastPath];
  }
  BOOL isFileURL = [documentUrl isFileURL];
  if(isFileURL) {
    [documentController openDocumentWithContentsOfURL:documentUrl
                                              display:YES
                                    completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
                                      
                                      if(error != nil){
                                        
                                        NSAlert *alert = [[NSAlert alloc] init];
                                        [alert setMessageText:   NSLocalizedString(@"FILE_OPEN_ERROR", "Error while reopening last known documents")];
                                        [alert setInformativeText: [error localizedDescription]];
                                        [alert setAlertStyle:NSCriticalAlertStyle ];
                                        [alert runModal];
                                      }
                                      
                                      if(document == nil){
                                        [self _showWelcomeWindow];
                                      }
                                      
                                    }];
  }
  return isFileURL;
}

@end
