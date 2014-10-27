//
//  MPServerSettingsController.h
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"
#import "MPSettingsTab.h"

@class DDHotKeyTextField;

@interface MPIntegrationSettingsController : MPViewController <MPSettingsTab, NSTextFieldDelegate>

@property (weak) IBOutlet NSButton *enableServerCheckbutton;
@property (weak) IBOutlet NSButton *enableGlobalAutotypeCheckbutton;
@property (weak) IBOutlet NSButton *enableQuicklookCheckbutton;
@property (weak) IBOutlet DDHotKeyTextField *hotKeyTextField;

@end
