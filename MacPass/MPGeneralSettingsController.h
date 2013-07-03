//
//  MPGeneralSettingsController.h
//  MacPass
//
//  Created by Michael Starke on 23.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPViewController.h"
#import "MPSettingsTab.h"

@interface MPGeneralSettingsController : MPViewController <MPSettingsTab>

@property (weak) IBOutlet NSButton *clearPasteboardOnQuitCheckButton;
@property (weak) IBOutlet NSPopUpButton *clearPasteboardTimeoutPopup;
@property (weak) IBOutlet NSPopUpButton *idleTimeOutPopup;
@property (weak) IBOutlet NSButton *lockOnSleepCheckButton;

@end
