//
//  MPAppDelegate.h
//  MacPass
//
//  Created by Michael Starke on 19.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
  MPContextMenuCreate = 1<<0,
  MPContextMenuDelete = 1<<1,
  MPContextMenuCopy = 1<<2,
  MPContextMenuMinimal = MPContextMenuCreate | MPContextMenuDelete,
  MPContextMenuFull = MPContextMenuMinimal | MPContextMenuCopy,
}MPContextMenuItemsFlags;

@class MPDatabaseDocument;

@interface MPAppDelegate : NSObject <NSApplicationDelegate>

@property (retain) IBOutlet NSWindow *passwordCreatorWindow;

- (IBAction)showPasswordCreator:(id)sender;

- (NSString *)applicationName;

/*
 Creates an array of menuitems to be used as a menu
 Automatically sets up actions, so you need to take care of the responder chain
 */
- (NSArray *)contextMenuItemsWithItems:(MPContextMenuItemsFlags)flags;

@end