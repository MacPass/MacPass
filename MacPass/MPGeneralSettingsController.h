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

@property (assign) IBOutlet NSButton *clearPasteboardOnQuitCheckButton;
@property (assign) IBOutlet NSPopUpButton *clearPasteboardTimeoutPopup;
@property (assign) IBOutlet NSPopUpButton *idleTimeOutPopup;
@property (assign) IBOutlet NSButton *lockOnSleepCheckButton;

@end
