//
//  MPToolbarDelegate.h
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

#import <AppKit/AppKit.h>

APPKIT_EXTERN NSString *const MPToolbarItemIdentifierLock;
APPKIT_EXTERN NSString *const MPToolbarItemIdentifierAddGroup;
APPKIT_EXTERN NSString *const MPToolbarItemIdentifierAddEntry;
APPKIT_EXTERN NSString *const MPToolbarItemIdentifierDelete;
APPKIT_EXTERN NSString *const MPToolbarItemIdentifierAction;
APPKIT_EXTERN NSString *const MPToolbarItemIdentifierInspector;
APPKIT_EXTERN NSString *const MPToolbarItemIdentifierSearch;
APPKIT_EXTERN NSString *const MPToolbarItemIdentifierCopyUsername;
APPKIT_EXTERN NSString *const MPToolbarItemIdentifierCopyPassword;
APPKIT_EXTERN NSString *const MPToolbarItemIdentifierHistory;
APPKIT_EXTERN NSString *const MPToolbarItemIdentifierAutotype;

@class MPDocument;

@interface MPToolbarDelegate : NSObject <NSToolbarDelegate, NSSearchFieldDelegate>

@property (weak, readonly) NSSearchField *searchField;
@property (weak) NSToolbar *toolbar;

- (void)registerNotificationsForDocument:(MPDocument *)document;

@end
