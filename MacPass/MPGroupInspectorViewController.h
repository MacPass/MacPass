//
//  MPGroupInspectorViewController.h
//  MacPass
//
//  Created by Michael Starke on 27.07.13.
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
@class MPDocument;
@class HNHUITextField;

@interface MPGroupInspectorViewController : MPViewController

@property (strong) IBOutlet NSView *contentView;
@property (strong) IBOutlet HNHUITextField *titleTextField;

@property (strong) IBOutlet NSButton *expiresCheckButton;
@property (strong) IBOutlet NSButton *expireDateSelectButton;

@property (strong) IBOutlet NSPopUpButton *searchPopupButton;
@property (strong) IBOutlet NSPopUpButton *autotypePopupButton;
@property (strong) IBOutlet HNHUITextField *autotypeSequenceTextField;
@property (strong) IBOutlet NSTokenField *tagsTokenField;

- (void)registerNotificationsForDocument:(MPDocument *)document;
@end
