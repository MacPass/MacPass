//
//  MPAppDelegate.m
//  MacPass
//
//  Created by Michael Starke on 19.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPAppDelegate.h"

#import "MPMainWindowController.h"
#import "MPSettingsController.h"
#import "MPDatabaseController.h"

@interface MPAppDelegate ()

@property (retain) MPSettingsController *settingsController;
@property (retain) MPMainWindowController *mainWindowController;

- (IBAction)showPreferences:(id)sender;
@end

@implementation MPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  self.mainWindowController = [[[MPMainWindowController alloc] init] autorelease];
  [self.mainWindowController showWindow:[self.mainWindowController window]];
}

- (void)dealloc {
  [_settingsController release];
  [_mainWindowController release];
  [super dealloc];
}

- (NSString *)applicationName {
  return [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
}

#pragma mark Menu Actions

- (void)showMainWindow:(id)sender {
  [self.mainWindowController showMainWindow:sender];
}

- (void)showPreferences:(id)sender {
  if(self.settingsController == nil) {
    self.settingsController = [[[MPSettingsController alloc] init] autorelease];
  }
  [self.settingsController showWindow:_settingsController.window];
}

- (void)toolbarItemPressed:(id)sender {
  NSLog(@"Pressed %@", sender);
}

@end
