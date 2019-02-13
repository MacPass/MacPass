//
//  MPEntryViewController.h
//  MacPass
//
//  Created by michael starke on 18.02.13.
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
#import "MPContextBarViewController.h"
#import "MPTargetNodeResolving.h"

APPKIT_EXTERN NSString *const MPEntryTableIndexColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableUserNameColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableTitleColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTablePasswordColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableParentColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableURLColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableNotesColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableAttachmentColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableModfiedColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableHistoryColumnIdentifier;

typedef NS_ENUM(NSUInteger, MPDisplayMode) {
  MPDisplayModeEntries,
  MPDisplayModeSearchResults,
  MPDisplayModeHistory
};

@class KPKEntry;
@class MPDocumentWindowController;
@class MPDocument;

@interface MPEntryViewController : MPViewController <NSTableViewDelegate, MPTargetNodeResolving>

@property (weak,readonly) NSTableView *entryTable;
@property (readonly, strong) NSArrayController *entryArrayController;
@property (readonly, assign) MPDisplayMode displayMode;

/* Call this after all view controllers are loaded */
- (void)registerNotificationsForDocument:(MPDocument *)document;

/* Copy/Paste */
- (IBAction)copyUsername:(id)sender;
- (IBAction)copyPassword:(id)sender;
- (IBAction)copyCustomAttribute:(id)sender;
- (IBAction)copyURL:(id)sender;
- (IBAction)openURL:(id)sender;
- (IBAction)copyAsReference:(id)sender;

/* More Actions */
- (IBAction)delete:(id)sender;
- (IBAction)revertToHistoryEntry:(id)sender;

@end

