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

/* Keepass HTTP */
@property (weak) IBOutlet NSButton *enableServerCheckBox;

/* Autotype */
@property (weak) IBOutlet NSButton *enableGlobalAutotypeCheckBox;
@property (weak) IBOutlet DDHotKeyTextField *hotKeyTextField;
@property (weak) IBOutlet NSTextField *hotkeyWarningTextField;

@property (weak) IBOutlet NSButton *matchURLCheckBox;
@property (weak) IBOutlet NSButton *matchHostCheckBox;
@property (weak) IBOutlet NSButton *matchTagsCheckBox;

@property (weak) IBOutlet NSButton *sendCommandForControlCheckBox;

/* Preview */
@property (weak) IBOutlet NSButton *enableQuicklookCheckBox;

@end
