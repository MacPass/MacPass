//
//  MPServerSettingsController.h
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "MPViewController.h"
#import "MPPreferencesTab.h"

@class DDHotKeyTextField;

@interface MPIntegrationPreferencesController : MPViewController <MPPreferencesTab, NSTextFieldDelegate>
/* Autotype */
@property (strong) IBOutlet NSButton *enableGlobalAutotypeCheckBox;
@property (strong) IBOutlet DDHotKeyTextField *hotKeyTextField;
@property (strong) IBOutlet NSTextField *hotkeyWarningTextField;

@property (strong) IBOutlet NSTextField *autotypeWarningTextField;
@property (strong) IBOutlet NSStackView *autotypeStackView;
@property (strong) IBOutlet NSButton *openPreferencesButton;
@property (strong) IBOutlet NSButton *matchTitleCheckBox;
@property (strong) IBOutlet NSButton *matchURLCheckBox;
@property (strong) IBOutlet NSButton *matchHostCheckBox;
@property (strong) IBOutlet NSButton *matchTagsCheckBox;

@property (strong) IBOutlet NSButton *sendCommandForControlCheckBox;
@property (strong) IBOutlet NSButton *alwaysShowConfirmationBeforeAutotypeCheckBox;
/* Preview */
@property (strong) IBOutlet NSButton *enableQuicklookCheckBox;

- (IBAction)runAutotypeDoctor:(id)sender;

@end
