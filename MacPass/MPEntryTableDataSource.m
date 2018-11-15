//
//  MPEntyTableDataSource.m
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

#import "MPEntryTableDataSource.h"
#import "MPEntryViewController.h"

#import "KeePassKit/KeePassKit.h"

@interface MPEntryTableDataSource ()

@end

@implementation MPEntryTableDataSource

// FIXME: change drag image to use only the first column regardless of drag start

- (id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row {
  if(MPDisplayModeHistory == self.viewController.displayMode) {
    return nil;
  }
  
  id item = self.viewController.entryArrayController.arrangedObjects[row];
  if([item isKindOfClass:KPKEntry.class]) {
    return item;
  }
  return nil;
}

- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forRowIndexes:(nonnull NSIndexSet *)rowIndexes {
  session.draggingFormation = NSDraggingFormationList;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
  /* we do not accept drops if we are in history or search display mode */
  if(self.viewController.displayMode != MPDisplayModeEntries) {
    return NSDragOperationNone;
  }
  BOOL isLocalDrag = info.draggingSource == tableView;
  if(isLocalDrag) {
    /* local drag is not usefull if the table is displaying sorted */
    NSArray<NSSortDescriptor *> * sortDescriptors = tableView.sortDescriptors;
    if(sortDescriptors.count != 0 && sortDescriptors.firstObject.key != NSStringFromSelector(@selector(index))) {
      return NSDragOperationNone;
    }
  }
  BOOL makeCopy = !isLocalDrag || (info.draggingSourceOperationMask == NSDragOperationCopy);
  
  if(dropOperation == NSTableViewDropOn) {
    [tableView setDropRow:row+1 dropOperation:NSTableViewDropAbove];
  }
  return makeCopy ? NSDragOperationCopy : NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
  if(dropOperation == NSTableViewDropAbove) {
    row = MAX(0, row - 1); // decrement the row
  }
  BOOL copyItems = info.draggingSourceOperationMask == NSDragOperationCopy;
  MPDocument *document = tableView.window.windowController.document;
  if(document.currentTargetGroups.count != 1) {
    return NO;
  }
  KPKGroup *targetGroup = document.currentTargetGroups.firstObject;
  /* local drag */
  if(info.draggingSource == tableView) {
    if(copyItems) {
      for(NSUUID *entryUUID in [self _readEntryUUIDsFromPasterboard:info.draggingPasteboard].reverseObjectEnumerator) {
        KPKEntry *entry = [[document findEntry:entryUUID] copyWithTitle:nil options:kKPKCopyOptionNone];
        [entry addToGroup:targetGroup atIndex:row];
        [entry.undoManager setActionName:NSLocalizedString(@"COPY_ENTRY", @"Action name when an entry was moved")];
      }
    }
    else {
      for(NSUUID *entryUUID in [self _readEntryUUIDsFromPasterboard:info.draggingPasteboard].reverseObjectEnumerator) {
        KPKEntry *entry = [document findEntry:entryUUID];
        [entry moveToGroup:entry.parent atIndex:row];
        [entry.undoManager setActionName:NSLocalizedString(@"MOVE_ENTRY", @"Action name when an entry was moved")];
      }
    }
    [self.viewController.entryArrayController rearrangeObjects];
    return YES;
  }
  else {
    // external drop
  }
  return NO;
}

- (NSArray<NSUUID *> *)_readEntryUUIDsFromPasterboard:(NSPasteboard *)pasteboard {
  if([pasteboard.types containsObject:KPKEntryUUDIUTI]) {
    if([pasteboard canReadObjectForClasses:@[NSUUID.class] options:nil]) {
      return [pasteboard readObjectsForClasses:@[NSUUID.class] options:nil];
    }
  }
  return @[];
}

- (NSArray<KPKEntry *> *)_readEntriesFromPasteboard:(NSPasteboard *)pasteboard {
  return @[];
}

@end
