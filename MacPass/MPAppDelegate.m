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

#pragma mark Menu Actions
- (void)showPreferences:(id)sender {
  if(self.settingsController == nil) {
    self.settingsController = [[[MPSettingsController alloc] init] autorelease];
  }
  [self.settingsController showWindow:_settingsController.window];
}

- (void)newDocument:(id)sender {
}

- (void)performClose:(id)sender {
  NSLog(@"Close");
}

- (void)openDocument:(id)sender {
  [self.mainWindowController openDocument];
}


@end
