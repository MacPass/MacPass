//
//  MPContextMenuHelper.h
//  MacPass
//
//  Created by Michael Starke on 09.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_OPTIONS(NSUInteger, MPContextMenuItemsFlags) {
  MPContextMenuCreate     = 1 << 0,
  MPContextMenuDelete     = 1 << 1,
  MPContextMenuCopy       = 1 << 2,
  MPContextMenuTrash      = 1 << 3,
  MPContextMenuDuplicate  = 1 << 4,
  MPContextMenuAutotype   = 1 << 5,
  MPContextMenuMinimal    = MPContextMenuCreate | MPContextMenuDelete,
  MPContextMenuFull       = MPContextMenuMinimal | MPContextMenuCopy | MPContextMenuDuplicate | MPContextMenuAutotype,
  MPContextMenuExtended   = MPContextMenuFull | MPContextMenuTrash
};

@interface MPContextMenuHelper : NSTableCellView

/*
 Creates an array of menuitems to be used as a menu
 Automatically sets up actions, so you need to take care of the responder chain
 */
+ (NSArray *)contextMenuItemsWithItems:(MPContextMenuItemsFlags)flags;

@end
