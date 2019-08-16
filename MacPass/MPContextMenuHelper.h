//
//  MPContextMenuHelper.h
//  MacPass
//
//  Created by Michael Starke on 09.06.13.
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

#import <Cocoa/Cocoa.h>

typedef NS_OPTIONS(NSUInteger, MPContextMenuItemsFlags) {
  MPContextMenuCreate             = 1 << 0,
  MPContextMenuDelete             = 1 << 1,
  MPContextMenuCopy               = 1 << 2,
  MPContextMenuTrash              = 1 << 3,
  MPContextMenuDuplicate          = 1 << 4,
  MPContextMenuAutotype           = 1 << 5,
  MPContextMenuHistory            = 1 << 6,
  MPContextMenuShowGroupInOutline = 1 << 7,
  MPContextMenuMinimal            = MPContextMenuCreate | MPContextMenuDelete | MPContextMenuDuplicate,
  MPContextMenuFull               = MPContextMenuMinimal | MPContextMenuCopy | MPContextMenuDuplicate | MPContextMenuAutotype | MPContextMenuHistory,
  MPContextMenuExtended           = MPContextMenuFull | MPContextMenuTrash
};

@interface MPContextMenuHelper : NSTableCellView

/*
 Creates an array of menuitems to be used as a menu
 Automatically sets up actions, so you need to take care of the responder chain
 */
+ (NSArray <NSMenuItem *> *)contextMenuItemsWithItems:(MPContextMenuItemsFlags)flags;

@end
