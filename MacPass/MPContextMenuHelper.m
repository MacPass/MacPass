//
//  MPContextMenuHelper.m
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

#import "MPContextMenuHelper.h"
#import "MPActionHelper.h"

#import "MPFlagsHelper.h"

static void MPContextmenuHelperBeginSection(NSMutableArray *items) {
  if(items.count > 0) {
    [items addObject:[NSMenuItem separatorItem]];
  }
}

@implementation MPContextMenuHelper

+ (NSArray<NSMenuItem *> *)contextMenuItemsWithItems:(MPContextMenuItemsFlags)flags {
  
  BOOL const insertCreate = MPIsFlagSetInOptions(MPContextMenuCreate, flags);
  BOOL const insertDelete = MPIsFlagSetInOptions(MPContextMenuDelete, flags);
  BOOL const insertCopy = MPIsFlagSetInOptions(MPContextMenuCopy, flags);
  BOOL const insertTrash = MPIsFlagSetInOptions(MPContextMenuTrash, flags);
  BOOL const insertDuplicate = MPIsFlagSetInOptions(MPContextMenuDuplicate, flags);
  BOOL const insertAutotype = MPIsFlagSetInOptions(MPContextMenuAutotype, flags);
  BOOL const insertHistory = MPIsFlagSetInOptions(MPContextMenuHistory, flags);
  BOOL const insertShowGroupInOutline = MPIsFlagSetInOptions(MPContextMenuShowGroupInOutline, flags);
  
  NSMutableArray *items = [NSMutableArray arrayWithCapacity:10];
  if(insertCreate) {
    
    NSMenuItem *newGroup = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"NEW_GROUP", @"Menu item to create a new group")
                                                      action:[MPActionHelper actionOfType:MPActionAddGroup]
                                               keyEquivalent:@"N"];
    NSMenuItem *newEntry = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"NEW_ENTRY", @"Menu item to create a new entry")
                                                      action:[MPActionHelper actionOfType:MPActionAddEntry]
                                               keyEquivalent:@"n"];
    
    [items addObjectsFromArray:@[ newGroup, newEntry ]];
  }
  if(insertDuplicate) {
    MPContextmenuHelperBeginSection(items);
    NSMenuItem *duplicateEntry = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DUPLICATE_ENTRY", @"Menu item to directly diplicate an entry")
                                                            action:[MPActionHelper actionOfType:MPActionDuplicateEntry]
                                                     keyEquivalent:@"D"];
    NSMenuItem *duplicateEntyWithOptions = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DUPLICATE_ENTRY_WITH_OPTIONS", @"Menu item to duplicate an entry with options how to duplicate. Will present a dialog.")
                                                                      action:[MPActionHelper actionOfType:MPActionDuplicateEntryWithOptions]
                                                               keyEquivalent:@""];
    NSMenuItem *duplicateGroup = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DUPLICATE_GROUP", @"Menu item to directly diplicate a group")
                                                            action:[MPActionHelper actionOfType:MPActionDuplicateGroup]
                                                     keyEquivalent:@""];

    [items addObjectsFromArray:@[ duplicateEntry, duplicateEntyWithOptions, duplicateGroup ]];
    
  }
  if(insertDelete || insertTrash) {
    MPContextmenuHelperBeginSection(items);
    if(insertDelete) {
      NSMenuItem *delete = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DELETE", @"Menu item to delete an entry")
                                                      action:[MPActionHelper actionOfType:MPActionDelete]
                                               keyEquivalent:[MPActionHelper keyEquivalentForAction:MPActionDelete]];
      [items addObject:delete];
      
    }
    if(insertTrash) {
      NSMenuItem *emptyTrash = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"EMPTY_TRASH", @"Menu item to empty the trash")
                                                          action:[MPActionHelper actionOfType:MPActionEmptyTrash]
                                                   keyEquivalent:@""];
      emptyTrash.keyEquivalentModifierMask = (NSShiftKeyMask | NSCommandKeyMask);
      unichar backSpace = NSBackspaceCharacter;
      emptyTrash.keyEquivalent = [NSString stringWithCharacters:&backSpace length:1];
      [items addObject:emptyTrash];
      
    }
  }
  if(insertCopy) {
    MPContextmenuHelperBeginSection(items);
    NSMenuItem *copyUsername = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"COPY_USERNAME", @"Menu item to copy the username of an entry")
                                                          action:[MPActionHelper actionOfType:MPActionCopyUsername]
                                                   keyEquivalent:@"C"];
    NSMenuItem *copyPassword = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"COPY_PASSWORD", @"Menu item to copy the password of an entry")
                                                          action:[MPActionHelper actionOfType:MPActionCopyPassword]
                                                   keyEquivalent:@"c"];
    copyPassword.keyEquivalentModifierMask = (copyPassword.keyEquivalentModifierMask | NSAlternateKeyMask);
    NSMenu *urlMenu = [[NSMenu alloc] init];
    NSMenuItem *urlItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"URL", @"Submenu with options what to do with the URL of an entry")
                                                     action:0
                                              keyEquivalent:@""];
    urlItem.submenu = urlMenu;
    
    NSMenuItem *copyURL = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"COPY_URL", @"Menu item to copy the URL of an entry")
                                                     action:[MPActionHelper actionOfType:MPActionCopyURL]
                                              keyEquivalent:@"u"];
    NSMenuItem *openURL = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"OPEN_URL", @"Menu item to open the URL with the default application")
                                                     action:[MPActionHelper actionOfType:MPActionOpenURL]
                                              keyEquivalent:@"U"];
    [urlMenu addItem:copyURL];
    [urlMenu addItem:openURL];
    
    [items addObjectsFromArray:@[ copyUsername, copyPassword, urlItem]];
  }
  if(insertAutotype || insertHistory || insertShowGroupInOutline) {
    MPContextmenuHelperBeginSection(items);
    if(insertAutotype) {
      NSMenuItem *performAutotype = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"PERFORM_AUTOTYPE_FOR_ENTRY", @"Menu item to perform autotype with the selected entry")
                                                               action:[MPActionHelper actionOfType:MPActionPerformAutotypeForSelectedEntry]
                                                        keyEquivalent:@"t"];
      [items addObject:performAutotype];
    }
    if(insertHistory) {
      NSMenuItem *showHistory = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"SHOW_HISTORY", @"Menu item to show the history of the selected entry")
                                                               action:[MPActionHelper actionOfType:MPActionShowEntryHistory]
                                                        keyEquivalent:@"h"];
      showHistory.keyEquivalentModifierMask = (showHistory.keyEquivalentModifierMask | NSCommandKeyMask | NSControlKeyMask);
      [items addObject:showHistory];
    }
    if(insertShowGroupInOutline) {
      NSMenuItem *showGroupInOutline = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"SHOW_GROUP_IN_OUTLINE", @"Menu item to show the entries group in the outline view")
                                                                  action:[MPActionHelper actionOfType:MPActionShowGroupInOutline]
                                                           keyEquivalent:@""];
      [items addObject:showGroupInOutline];
    }
  }
  
  return items;
}

@end
