//
//  MPSecurityPreferencesController.h
//  MacPass
//
//  Created by Michael Starke on 11.04.25.
//  Copyright © 2025 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPViewController.h"
#import "MPPreferencesTab.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPSecurityPreferencesController : MPViewController <MPPreferencesTab>

@property (strong) IBOutlet NSButton *clearPasteboardOnQuitCheckButton;
@property (strong) IBOutlet NSPopUpButton *clearPasteboardTimeoutPopup;
@property (strong) IBOutlet NSButton *preventUniversalClipboardSupportCheckButton;
@property (strong) IBOutlet NSPopUpButton *idleTimeOutPopup;
@property (strong) IBOutlet NSButton *lockOnSleepCheckButton;
@property (strong) IBOutlet NSButton *lockOnLogoutCheckButton;
@property (strong) IBOutlet NSButton *lockOnScreenSleepCheckButton;
@property (strong) IBOutlet NSButton *rememberKeyFileCheckButton;
@property (strong) IBOutlet NSButton *allowScreenshotsCheckButton;

@end

NS_ASSUME_NONNULL_END
