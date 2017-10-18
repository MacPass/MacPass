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
#import "MPSettingsTab.h"

@class DDHotKeyTextField;

@interface MPIntegrationSettingsController : MPViewController <MPSettingsTab, NSTextFieldDelegate>
/* Autotype */
@property (weak) IBOutlet NSButton *enableGlobalAutotypeCheckBox;
@property (weak) IBOutlet DDHotKeyTextField *hotKeyTextField;
@property (weak) IBOutlet NSTextField *hotkeyWarningTextField;

@property (weak) IBOutlet NSButton *matchTitleCheckBox;
@property (weak) IBOutlet NSButton *matchURLCheckBox;
@property (weak) IBOutlet NSButton *matchHostCheckBox;
@property (weak) IBOutlet NSButton *matchTagsCheckBox;

@property (weak) IBOutlet NSButton *sendCommandForControlCheckBox;

/* Preview */
@property (weak) IBOutlet NSButton *enableQuicklookCheckBox;

@end
