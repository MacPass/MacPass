//
//  MPSavePanelAccessoryViewController.h
//  MacPass
//
//  Created by Michael Starke on 10.08.13.
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
#import "KeePassKit/KeePassKit.h"

@class MPDocument;

@interface MPSavePanelAccessoryViewController : MPViewController

@property (nonatomic, weak) NSSavePanel *savePanel;
@property (nonatomic, weak) MPDocument *document;
@property (nonatomic, assign, readonly) KPKDatabaseFormat selectedVersion;

@property (nonatomic, weak) IBOutlet NSPopUpButton *fileTypePopupButton;
@property (nonatomic, weak) IBOutlet NSTextField *infoTextField;
/**
 *	Updates the view to current state
 */
- (void)updateView;

@end
