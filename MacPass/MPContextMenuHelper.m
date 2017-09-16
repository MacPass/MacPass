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

+ (NSArray *)contextMenuItemsWithItems:(MPContextMenuItemsFlags)flags {
  
  BOOL const insertCreate = MPIsFlagSetInOptions(MPContextMenuCreate, flags);
  BOOL const insertDelete = MPIsFlagSetInOptions(MPContextMenuDelete, flags);
  BOOL const insertCopy = MPIsFlagSetInOptions(MPContextMenuCopy, flags);
  BOOL const insertTrash = MPIsFlagSetInOptions(MPContextMenuTrash, flags);
  BOOL const insertDuplicate = MPIsFlagSetInOptions(MPContextMenuDuplicate, flags);
  BOOL const insertAutotype = MPIsFlagSetInOptions(MPContextMenuAutotype, flags);
  BOOL const insertHistory = MPIsFlagSetInOptions(MPContextMenuHistory, flags);
  
  NSMutableArray *items = [NSMutableArray arrayWithCapacity:10];
  if(insertCreate) {
    
    NSMenuItem *newGroup = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"ADD_GROUP", @"")
                                                      action:[MPActionHelper actionOfType:MPActionAddGroup]
                                               keyEquivalent:@"G"];
    NSMenuItem *newEntry = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"ADD_ENTRY", @"")
                                                      action:[MPActionHelper actionOfType:MPActionAddEntry]
                                               keyEquivalent:@"E"];
    
    [items addObjectsFromArray:@[ newGroup, newEntry ]];
  }
  if(insertDuplicate) {
    MPContextmenuHelperBeginSection(items);
    NSMenuItem *duplicateEntry = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DUPLICATE_ENTRY", @"")
                                                            action:[MPActionHelper actionOfType:MPActionDuplicateEntry]
                                                     keyEquivalent:@"D"];
    NSMenuItem *duplicateEntyWithOptions = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DUPLICATE_ENTRY_WITH_OPTIONS", @"")
                                                                      action:[MPActionHelper actionOfType:MPActionDuplicateEntryWithOptions]
                                                               keyEquivalent:@""];
    
    [items addObjectsFromArray:@[ duplicateEntry, duplicateEntyWithOptions ]];
    
  }
  if(insertDelete || insertTrash) {
    MPContextmenuHelperBeginSection(items);
    if(insertDelete) {
      NSMenuItem *delete = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DELETE", @"")
                                                      action:[MPActionHelper actionOfType:MPActionDelete]
                                               keyEquivalent:[MPActionHelper keyEquivalentForAction:MPActionDelete]];
      [items addObject:delete];
      
    }
    if(insertTrash) {
      NSMenuItem *emptyTrash = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"EMPTY_TRASH", @"")
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
    NSMenuItem *copyUsername = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"COPY_USERNAME", @"")
                                                          action:[MPActionHelper actionOfType:MPActionCopyUsername]
                                                   keyEquivalent:@"C"];
    NSMenuItem *copyPassword = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"COPY_PASSWORD", @"")
                                                          action:[MPActionHelper actionOfType:MPActionCopyPassword]
                                                   keyEquivalent:@"c"];
    copyPassword.keyEquivalentModifierMask = (copyPassword.keyEquivalentModifierMask | NSAlternateKeyMask);
    NSMenu *urlMenu = [[NSMenu alloc] init];
    NSMenuItem *urlItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"URL", @"")
                                                     action:0
                                              keyEquivalent:@""];
    urlItem.submenu = urlMenu;
    
    NSMenuItem *copyURL = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"COPY_URL", @"")
                                                     action:[MPActionHelper actionOfType:MPActionCopyURL]
                                              keyEquivalent:@"u"];
    NSMenuItem *openURL = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"OPEN_URL", @"")
                                                     action:[MPActionHelper actionOfType:MPActionOpenURL]
                                              keyEquivalent:@"U"];
    [urlMenu addItem:copyURL];
    [urlMenu addItem:openURL];
    
    [items addObjectsFromArray:@[ copyUsername, copyPassword, urlItem]];
  }
  if(insertAutotype || insertHistory) {
    MPContextmenuHelperBeginSection(items);
    if(insertAutotype) {
      NSMenuItem *performAutotype = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"PERFORM_AUTOTYPE_FOR_ENTRY", @"")
                                                               action:[MPActionHelper actionOfType:MPActionPerformAutotypeForSelectedEntry]
                                                        keyEquivalent:@"a"];
      performAutotype.keyEquivalentModifierMask = (performAutotype.keyEquivalentModifierMask | NSControlKeyMask);
      [items addObject:performAutotype];
    }
    if(insertHistory) {
      NSMenuItem *showHistory = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"SHOW_HISTORY", @"")
                                                               action:[MPActionHelper actionOfType:MPActionShowEntryHistory]
                                                        keyEquivalent:@"h"];
      showHistory.keyEquivalentModifierMask = (showHistory.keyEquivalentModifierMask | NSCommandKeyMask | NSControlKeyMask);
      [items addObject:showHistory];
    }
  }
  
  return items;
}

@end
