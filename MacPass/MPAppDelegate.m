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
#import "MPServerDaemon.h"
#import "MPLockDaemon.h"
#import "MPDocumentWindowController.h"

@interface MPAppDelegate () {
@private
  MPServerDaemon *serverDaemon;
  MPLockDaemon *lockDaemon;
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
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
  return [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyOpenEmptyDatabaseOnLaunch];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  serverDaemon = [[MPServerDaemon alloc] init];
  lockDaemon = [[MPLockDaemon alloc] init];
}


- (NSString *)applicationName {
  return [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
}

#pragma mark Menu Actions
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
    //NSView *contentView = [_passwordCreatorWindow contentView];
    [self.passwordCreatorWindow setContentView:creatorView];
    //[contentView addSubview:creatorView];
//    [[_passwordCreatorWindow contentView] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[creatorView]|"
//                                                                                                 options:0
//                                                                                                 metrics:nil
//                                                                                                   views:NSDictionaryOfVariableBindings(creatorView)]];
//    [[_passwordCreatorWindow contentView] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[creatorView]|"
//                                                                                                 options:0
//                                                                                                 metrics:nil
//                                                                                                   views:NSDictionaryOfVariableBindings(creatorView)]];
//    [contentView layoutSubtreeIfNeeded];
  }
  
  [self.passwordCreatorWindow makeKeyAndOrderFront:self.passwordCreatorWindow];
}

- (void)lockAllDocuments {
  for(NSDocument *document in [[NSDocumentController sharedDocumentController] documents]) {
    NSArray *windowControllers = [document windowControllers];
    if([windowControllers count] > 0) {
      [windowControllers[0] lock:nil];
    }
  }
}

@end
