//
//  MPAppDelegate.m
//  MacPass
//
//  Created by Michael Starke on 19.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPAppDelegate.h"

#import "MPSettingsWindowController.h"
#import "MPPasswordCreatorViewController.h"
#import "MPSettingsHelper.h"
#import "MPUppercaseStringValueTransformer.h"
#import "MPStringLengthValueTransformer.h"
#import "MPStripLineBreaksTransformer.h"
#import "MPServerDaemon.h"
#import "MPLockDaemon.h"
#import "MPAutotypeDaemon.h"
#import "MPDocumentWindowController.h"

@interface MPAppDelegate () {
@private
  MPServerDaemon *serverDaemon;
  MPLockDaemon *lockDaemon;
  MPAutotypeDaemon *autotypeDaemon;
  BOOL _restoredWindows;
  BOOL _shouldOpenFile;
}

@property (strong, nonatomic) MPSettingsWindowController *settingsController;
@property (strong, nonatomic) MPPasswordCreatorViewController *passwordCreatorController;

- (IBAction)showPreferences:(id)sender;

@end

@implementation MPAppDelegate

+ (void)initialize {
  [MPSettingsHelper setupDefaults];
  [MPUppercaseStringValueTransformer registerTransformer];
  [MPStringLengthValueTransformer registerTransformer];
  [MPStripLineBreaksTransformer registerTransformer];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
  return [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyOpenEmptyDatabaseOnLaunch];
}


- (void)applicationWillFinishLaunching:(NSNotification *)notification {
  BOOL reopen = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyReopenLastDatabaseOnLaunch];
  _restoredWindows = NO;
  _shouldOpenFile = NO;
  if(reopen) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationDidFinishRestoringWindows:)
                                                 name:NSApplicationDidFinishRestoringWindowsNotification
                                               object:nil];

  }
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
  //autotypeDaemon = [[MPAutotypeDaemon alloc] init];

  BOOL reopen = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyReopenLastDatabaseOnLaunch];
  if(reopen && !_restoredWindows && !_shouldOpenFile) {
    NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
    NSArray *documents = [documentController documents];
    if([documents count] > 0) {
      return; // There's a document open
    }
    
    NSArray *recentDocuments = [documentController recentDocumentURLs];
    NSURL *documentUrl;
    if([recentDocuments count] > 0) {
      documentUrl = recentDocuments[0];
    }
    else {
      NSString *lastPath = [[NSUserDefaults standardUserDefaults] stringForKey:kMPSettingsKeyLastDatabasePath];
      documentUrl = [NSURL URLWithString:lastPath];
    }
    if([documentUrl isFileURL]) {
      [documentController openDocumentWithContentsOfURL:documentUrl display:YES
                                      completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {}];
      
    }
    else {
      NSArray *topLevelObject;
      [[NSBundle mainBundle] loadNibNamed:@"WelcomeWindow" owner:self topLevelObjects:&topLevelObject];
      [self.welcomeWindow orderFront:self];
    }
  }
}

- (NSString *)applicationName {
  return [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
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
    NSView *creatorView = [_passwordCreatorController view];
    [self.passwordCreatorWindow setContentView:creatorView];
  }
  
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

- (void)_applicationDidFinishRestoringWindows:(NSNotification *)notification {
  NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
  NSArray *documents = [documentController documents];
  _restoredWindows = [documents count] > 0;
}

@end
