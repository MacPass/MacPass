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
#import "MPDockTileHelper.h"
#import "MPDocument.h"
#import "MPDocumentController.h"
#import "MPDocumentWindowController.h"
#import "MPLockDaemon.h"
#import "MPPasswordCreatorViewController.h"
#import "MPServerDaemon.h"
#import "MPSettingsHelper.h"
#import "MPSettingsWindowController.h"
#import "MPStringLengthValueTransformer.h"
#import "MPTemporaryFileStorageCenter.h"
#import "MPValueTransformerHelper.h"

#import "KPKCompositeKey.h"

NSString *const MPDidChangeStoredKeyFilesSettings = @"com.hicknhack.macpass.MPDidChangeStoredKeyFilesSettings";

@interface MPAppDelegate () {
@private
  MPServerDaemon *serverDaemon;
  MPLockDaemon *lockDaemon;
  MPDockTileHelper *dockTileHelper;
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
  [MPValueTransformerHelper registerValueTransformer];
}

- (instancetype)init {
  self = [super init];
  if(self) {
    /* We know that we do not use the varibale after instancation */
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wunused-variable"
    MPDocumentController *documentController = [[MPDocumentController alloc] init];
    #pragma clang diagnostic pop
  }
  return self;
}

- (void)dealloc {
  [self unbind:NSStringFromSelector(@selector(isAllowedToStoreKeyFile))];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
  [[self.saveMenuItem menu] setDelegate:self];
  
  /* We want to inform anyone about the changes to keyFile remmebering */
  [self bind:NSStringFromSelector(@selector(isAllowedToStoreKeyFile))
    toObject:[NSUserDefaultsController sharedUserDefaultsController]
 withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyRememberKeyFilesForDatabases]
     options:nil];
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
  [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:fileURL display:YES completionHandler:nil];
  return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  serverDaemon = [[MPServerDaemon alloc] init];
  lockDaemon = [[MPLockDaemon alloc] init];
  self.autotypeDaemon = [[MPAutotypeDaemon alloc] init];
  //dockTileHelper = [[MPDockTileHelper alloc] init];
}

- (NSString *)applicationName {
  return [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
}

#pragma mark -
#pragma mark NSMenuDelegate
- (void)menuNeedsUpdate:(NSMenu *)menu {
  if([self.saveMenuItem menu] != menu) {
    return; // wrong menu
  }
  MPDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
  BOOL displayDots = (document.fileURL == nil || !document.compositeKey.hasPasswordOrKeyFile);
  NSString *saveTitle =  displayDots ? NSLocalizedString(@"SAVE_WITH_DOTS", "") : NSLocalizedString(@"SAVE", "");
  [self.saveMenuItem setTitle:saveTitle];
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
    self.passwordCreatorController.closeTarget = self.passwordCreatorWindow;
    NSView *creatorView = [_passwordCreatorController view];
    [self.passwordCreatorWindow setContentView:creatorView];
    [self.passwordCreatorController updateResponderChain];
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
  for(NSDocument *document in [[NSDocumentController sharedDocumentController] documents]) {
    NSArray *windowControllers = [document windowControllers];
    if([windowControllers count] > 0) {
      [windowControllers[0] lock:nil];
    }
  }
}

- (void)clearRememberdKeyFiles:(id)sender {
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMPSettingsKeyRememeberdKeysForDatabases];
}


#pragma mark -
#pragma mark Private Helper
- (void)_applicationDidFinishRestoringWindows:(NSNotification *)notification {
  NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
  NSArray *documents = [documentController documents];
  BOOL restoredWindows = [documents count] > 0;
  
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
                                    completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {}];
  }
  return isFileURL;
}

@end
