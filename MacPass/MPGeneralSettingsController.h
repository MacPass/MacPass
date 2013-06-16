//
//  MPGeneralSettingsController.h
//  MacPass
//
//  Created by Michael Starke on 23.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPSettingsTab.h"

@interface MPGeneralSettingsController : NSViewController <MPSettingsTab>
@property (assign) IBOutlet NSImageView *imageView;
@property (assign) IBOutlet NSButton *clearPasteboardOnQuitCheckButton;
@property (assign) IBOutlet NSPopUpButton *clearPasteboardTimeoutPopup;

@end
