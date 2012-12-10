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

@interface MPAppDelegate ()
@property (retain) MPSettingsController *settingsController;
@property (retain) MPMainWindowController *mainWindowController;
- (IBAction)showPreferences:(id)sender;
@end

@implementation MPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  _mainWindowController = [[MPMainWindowController alloc] init];
  [_mainWindowController showWindow:[_mainWindowController window]];
}

#pragma mark IBActions
- (void)showPreferences:(id)sender {
  if(_settingsController == nil) {
    _settingsController = [[MPSettingsController alloc] init];
  }
  [_settingsController showWindow:_settingsController.window];
}

@end
