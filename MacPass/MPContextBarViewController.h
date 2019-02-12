//
//  MPContextBarViewController.h
//  MacPass
//
//  Created by Michael Starke on 16/12/13.
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
#import "MPDocument.h"

@class MPDocument;

@interface MPContextBarViewController : MPViewController <NSStackViewDelegate>

@property (weak) IBOutlet NSButton *titleButton;
@property (weak) IBOutlet NSButton *usernameButton;
@property (weak) IBOutlet NSButton *passwordButton;
@property (weak) IBOutlet NSButton *urlButton;
@property (weak) IBOutlet NSButton *notesButton;
@property (weak) IBOutlet NSPopUpButton *specialFilterPopUpButton;
@property (weak) IBOutlet NSButton *everywhereButton;

- (void)registerNotificationsForDocument:(MPDocument *)document;

@end
