//
//  MPMainWindowController.h
//  MacPass
//
//  Created by Michael Starke on 24.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
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

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "MPPasswordEditWindowController.h"

@class MPViewController;
@class MPEntryViewController;
@class MPInspectorViewController;
@class MPPasswordInputController;
@class MPOutlineViewController;
@class MPToolbarDelegate;

@interface MPDocumentWindowController : NSWindowController <NSTouchBarDelegate>

@property (readonly, strong) MPPasswordInputController *passwordInputController;
@property (readonly, strong) MPToolbarDelegate *toolbarDelegate;

@property (readonly, nonatomic, strong) NSSearchField *searchField;

- (void)showEntries;
- (void)showPasswordInput;
- (void)showPasswordInputWithMessage:(NSString *)message;
- (void)editPasswordWithCompetionHandler:(void (^)(NSInteger result))handler;

#pragma mark Actions
- (IBAction)saveDocument:(id)sender;
- (IBAction)saveDocumentAs:(id)sender;

- (IBAction)editPassword:(id)sender;
- (IBAction)showDatabaseSettings:(id)sender;
- (IBAction)editTemplateGroup:(id)sender;
- (IBAction)editTrashGroup:(id)sender;

- (IBAction)exportAsXML:(id)sender;
- (IBAction)mergeWithOther:(id)sender;
- (IBAction)importFromXML:(id)sender;
- (IBAction)importWithPlugin:(id)sender;
- (IBAction)exportWithPlugin:(id)sender;

- (IBAction)lock:(id)sender;
- (IBAction)createGroup:(id)sender;
- (IBAction)createEntry:(id)sender;
- (IBAction)delete:(id)sender;

- (IBAction)duplicateEntryWithOptions:(id)sender;
- (IBAction)pickExpiryDate:(id)sender;
- (IBAction)performAutotypeForEntry:(id)sender;

- (IBAction)showGroupInOutline:(id)sender;

/* actions relayed to MPEntryViewController */
- (IBAction)copyUsername:(id)sender;
- (IBAction)copyPassword:(id)sender;
- (IBAction)copyCustomAttribute:(id)sender;
- (IBAction)copyAsReference:(id)sender;
- (IBAction)copyURL:(id)sender;
- (IBAction)openURL:(id)sender;

#pragma mark Helper
- (IBAction)fixAutotype:(id)sender;

#pragma mark View Actions
- (IBAction)toggleInspector:(id)sender;
- (IBAction)showInspector:(id)sender;
- (IBAction)focusGroups:(id)sender;
- (IBAction)focusEntries:(id)sender;
- (IBAction)focusInspector:(id)sender;

@end
