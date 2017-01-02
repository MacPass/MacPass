//
//  MPWorkflowSettingsController.h
//  MacPass
//
//  Created by Michael Starke on 30.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"
#import "MPSettingsTab.h"

@interface MPWorkflowSettingsController : MPViewController <MPSettingsTab>

@property (weak) IBOutlet NSPopUpButton *browserPopup;
@property (weak) IBOutlet NSPopUpButton *doubleClickURLPopup;
@property (weak) IBOutlet NSPopUpButton *doubleClickTitlePopup;
@property (weak) IBOutlet NSButton *updatePasswordOnTemplateEntriesCheckButton;

- (IBAction)_showCustomBrowserSelection:(id)sender;

@end
