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

@interface MPAppDelegate ()

@property (retain, nonatomic) MPSettingsWindowController *settingsController;
@property (retain, nonatomic) MPPasswordCreatorViewController *passwordCreatorController;

- (IBAction)showPreferences:(id)sender;

@end

@implementation MPAppDelegate

+ (void)initialize {
  [MPSettingsHelper setupDefaults];
  [MPUppercaseStringValueTransformer registerTransformer];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
  return [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyOpenEmptyDatabaseOnLaunch];
}

- (void)dealloc {
  [_settingsController release];
  [_passwordCreatorController release];
  [super dealloc];
}

- (NSString *)applicationName {
  return [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
}

#pragma mark Menu Actions
- (void)showPreferences:(id)sender {
  if(self.settingsController == nil) {
    self.settingsController = [[[MPSettingsWindowController alloc] init] autorelease];
  }
  [self.settingsController showSettings];
}

- (void)showPasswordCreator:(id)sender {
  if(!self.passwordCreatorWindow) {
    [[NSBundle mainBundle] loadNibNamed:@"PasswordCreatorWindow"owner:self topLevelObjects:nil];
  }
  if(!self.passwordCreatorController) {
    self.passwordCreatorController = [[[MPPasswordCreatorViewController alloc] init] autorelease];
  }
  [self.passwordCreatorWindow setContentView:[self.passwordCreatorController view]];
  [self.passwordCreatorWindow makeKeyAndOrderFront:self.passwordCreatorWindow];
}

@end
