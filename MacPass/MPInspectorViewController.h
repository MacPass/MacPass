//
//  MPInspectorTabViewController.h
//  MacPass
//
//  Created by Michael Starke on 05.03.13.
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

@class HNHUIGradientView;
@class MPIconImageView;

@interface MPInspectorViewController : MPViewController <NSPopoverDelegate>

@property (weak) IBOutlet HNHUIGradientView *bottomBar;
@property (weak) IBOutlet NSTextField *createdTextField;
@property (weak) IBOutlet NSTextField *modifiedTextField;
@property (weak) IBOutlet NSTextField *noSelectionInfo;
@property (weak) IBOutlet MPIconImageView *itemImageView;
@property (weak) IBOutlet NSTextField *itemNameTextField;
@property (weak) IBOutlet NSButton *saveChangesButton;
@property (weak) IBOutlet NSButton *discardChangesButton;

- (IBAction)pickIcon:(id)sender;
- (IBAction)pickExpiryDate:(id)sender;
- (IBAction)showPluginData:(id)sender;

/* Separate call to ensure all registered objects are in place */
- (void)registerNotificationsForDocument:(NSDocument *)document;



@end
