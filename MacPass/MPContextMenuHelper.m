//
//  MPContextMenuHelper.m
//  MacPass
//
//  Created by Michael Starke on 09.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPContextMenuHelper.h"
#import "MPActionHelper.h"

@implementation MPContextMenuHelper

+ (NSArray *)contextMenuItemsWithItems:(MPContextMenuItemsFlags)flags {
  BOOL insertCreate = (0 != (flags & MPContextMenuCreate));
  BOOL insertDelete = (0 != (flags & MPContextMenuDelete));
  BOOL insertCopy = (0 != (flags & MPContextMenuCopy));
  BOOL insertTrash = (0 != (flags & MPContextMenuTrash));
  
  NSMutableArray *items = [NSMutableArray arrayWithCapacity:10];
  if(insertCreate) {
    
    NSMenuItem *newGroup = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"ADD_GROUP", @"")
                                                      action:[MPActionHelper actionOfType:MPActionAddGroup]
                                               keyEquivalent:@"G"];
    NSMenuItem *newEntry = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"ADD_ENTRY", @"")
                                                      action:[MPActionHelper actionOfType:MPActionAddEntry]
                                               keyEquivalent:@"E"];
    
    [items addObjectsFromArray:@[ newGroup, newEntry ]];
    [newEntry release];
    [newGroup release];
  }
  if(insertDelete || insertTrash) {
    [self _beginSection:items];
    if(insertDelete) {
      NSMenuItem *delete = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DELETE", @"")
                                                      action:[MPActionHelper actionOfType:MPActionDelete]
                                               keyEquivalent:@""];
      [items addObject:delete];
      [delete release];

    }
    if(insertTrash) {
      NSMenuItem *emptyTrash = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"EMPTY_TRASH", @"")
                                                      action:[MPActionHelper actionOfType:MPActionEmptyTrash]
                                               keyEquivalent:@""];
      [emptyTrash setKeyEquivalentModifierMask:(NSShiftKeyMask | NSCommandKeyMask)];
      unichar backSpace = NSBackspaceCharacter;
      [emptyTrash setKeyEquivalent:[NSString stringWithCharacters:&backSpace length:1]];
      [items addObject:emptyTrash];
      [emptyTrash release];

    }
  }
  if(insertCopy) {
    [self _beginSection:items];
    NSMenuItem *copyUsername = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"COPY_USERNAME", @"")
                                                          action:[MPActionHelper actionOfType:MPActionCopyUsername]
                                                   keyEquivalent:@"C"];
    NSMenuItem *copyPassword = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"COPY_PASSWORD", @"")
                                                          action:[MPActionHelper actionOfType:MPActionCopyPassword]
                                                   keyEquivalent:@"c"];
    [copyPassword setKeyEquivalentModifierMask:[copyPassword keyEquivalentModifierMask] | NSAlternateKeyMask];
    NSMenu *urlMenu = [[NSMenu alloc] init];
    NSMenuItem *urlItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"URL", @"")
                                                     action:0
                                              keyEquivalent:@""];
    [urlItem setSubmenu:urlMenu];
    [urlMenu release];
    
    NSMenuItem *copyURL = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"COPY_URL", @"")
                                                     action:[MPActionHelper actionOfType:MPActionCopyURL]
                                              keyEquivalent:@"u"];
    NSMenuItem *openURL = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"OPEN_URL", @"")
                                                     action:[MPActionHelper actionOfType:MPActionOpenURL]
                                              keyEquivalent:@"U"];
    [urlMenu addItem:copyURL];
    [urlMenu addItem:openURL];
    [openURL release];
    [copyURL release];
    
    [items addObjectsFromArray:@[ copyUsername, copyPassword, urlItem]];
    [urlItem release];
    [copyPassword release];
    [copyUsername release];
  }
  
  return items;
}

+ (void)_beginSection:(NSMutableArray *)items {
  if([items count] > 0) {
    [items addObject:[NSMenuItem separatorItem]];
  }
}

@end
