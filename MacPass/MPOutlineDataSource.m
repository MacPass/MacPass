//
//  MPOutlineDataSource.m
//  MacPass
//
//  Created by Michael Starke on 19.07.12.
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

#import "MPOutlineDataSource.h"
#import "MPDocument.h"
#import "MPConstants.h"
#import "NSIndexPath+MPAdditions.h"

#import "KeePassKit/KeePassKit.h"

@interface MPOutlineDataSource ()

@property (strong) NSArray<KPKGroup *> *draggedGroups;

@end

@implementation MPOutlineDataSource

- (id<NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item {
  id representedObject = [item representedObject];
  if([representedObject isKindOfClass:KPKGroup.class]) {
    KPKGroup *group = representedObject;
    return group;
  }
  return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItems:(NSArray *)draggedItems {
  session.draggingFormation = NSDraggingFormationList;
  self.draggedGroups = @[];
  NSMutableArray *localDraggedGroups = [[NSMutableArray alloc] init];
  for(NSTreeNode *node in draggedItems) {
    BOOL addNode = YES;
    for(NSTreeNode *otherNode in draggedItems) {
      if(node == otherNode) {
        continue;
      }
      addNode &= ![otherNode.indexPath containsIndexPath:node.indexPath];
    }
    if(addNode) {
      KPKGroup *group = node.representedObject;
      [localDraggedGroups addObject:group];
    }
  }
  self.draggedGroups = [localDraggedGroups copy];
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
  info.animatesToDestination = YES;
  
  id targetItem = [item representedObject];
  if( ![targetItem isKindOfClass:KPKGroup.class] ) {
    return NSDragOperationNone; // Block all unknown types
  }
  
  BOOL copyDrag = (info.draggingSourceOperationMask == NSDragOperationCopy);
  
  KPKGroup *targetGroup = targetItem;
  BOOL isGroupDrop = (info.draggingSource == outlineView);
  BOOL isEntryDrop = (!isGroupDrop && [info.draggingSource window] == outlineView.window);
  if(isGroupDrop) {
    /* local group drop */
    for(KPKGroup *draggedGroup in self.draggedGroups) {
      BOOL validTarget = YES;
      if(targetGroup == draggedGroup) {
        return copyDrag ? NSDragOperationCopy : NSDragOperationNone;
      }
      
      if(draggedGroup.parent == targetGroup) {
        if(index == NSOutlineViewDropOnItemIndex) {
          return copyDrag ? NSDragOperationCopy : NSDragOperationNone;
        }
        validTarget &= index != draggedGroup.index;
      }
      BOOL isAnchesor = [draggedGroup isAnchestorOf:targetGroup];
      validTarget &= !isAnchesor;
      if(!validTarget) {
        return NSDragOperationNone;
      }
    }
    return copyDrag ? NSDragOperationCopy : NSDragOperationMove;
  }
  else if(isEntryDrop) {
    /* local entry drop */
    MPDocument *document = outlineView.window.windowController.document;
    NSUUID *entryUUID = [self _entryUUIDsFromPasteboard:info.draggingPasteboard].firstObject;
    KPKEntry *entry = [document findEntry:entryUUID];
    // FIXME: set correct item when drop is proposed between items
    if(index != NSOutlineViewDropOnItemIndex) {
      NSTreeNode *node = item;
      NSUInteger dropIndex = MIN(node.childNodes.count-1, index);
      id dropItem = node.childNodes[dropIndex];
      [outlineView setDropItem:dropItem dropChildIndex:NSOutlineViewDropOnItemIndex];
    }
    else {
      [outlineView setDropItem:item dropChildIndex:NSOutlineViewDropOnItemIndex];
    }
    if(entry.parent == targetItem) {
      return copyDrag ? NSDragOperationCopy : NSDragOperationNone;
    }
    return copyDrag ? NSDragOperationCopy : NSDragOperationMove;
  }
  else {
    /* extern drop */
    if([info.draggingPasteboard.types containsObject:KPKEntryUUDIUTI]) {
      [outlineView setDropItem:item dropChildIndex:NSOutlineViewDropOnItemIndex];
    }
    return NSDragOperationCopy;
  }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
  info.animatesToDestination = YES;
  
  id targetItem = [item representedObject];
  if(![targetItem isKindOfClass:KPKGroup.class]) {
    return NO; // Wrong
  }
  
  BOOL copyItem = (info.draggingSourceOperationMask == NSDragOperationCopy);
  
  KPKGroup *targetGroup = targetItem;
  MPDocument *document = outlineView.window.windowController.document;
  /* local drop */
  if(info.draggingSource == outlineView) {
    if(copyItem) {
      NSUInteger insertIndex = index;
      for(KPKGroup *group in self.draggedGroups.reverseObjectEnumerator) {
        KPKGroup *groupCopy = [group copyWithTitle:nil options:kKPKCopyOptionNone];
        [groupCopy addToGroup:targetGroup atIndex:insertIndex];
        insertIndex = groupCopy.index;
        [groupCopy.undoManager setActionName:NSLocalizedString(@"COPY_GROUP", "Action title for copying a group via drag and drop")];
      }
      return YES;
    }
    else {
      NSUInteger insertIndex = index;
      for(KPKGroup *group in self.draggedGroups.reverseObjectEnumerator) {
        [group moveToGroup:targetGroup atIndex:insertIndex];
        insertIndex = group.index;
        [group.undoManager setActionName:NSLocalizedString(@"DRAG_GROUP", "Action title for moving a group via drag and drop")];
      }
      return YES;
    }
  }
  else if([info.draggingSource window] == outlineView.window) {
    NSArray<NSUUID *> *entryUUIDs = [self _entryUUIDsFromPasteboard:info.draggingPasteboard];
    if(copyItem) {
      for(NSUUID *entryUUID in entryUUIDs) {
        KPKEntry *draggedEntry = [[document findEntry:entryUUID] copyWithTitle:nil options:kKPKCopyOptionNone];
        [draggedEntry addToGroup:targetGroup];
        [draggedEntry.undoManager setActionName:NSLocalizedString(@"COPY_ENTRY", "Action title for copying an entry via drag and drop")];
      }
    }
    else {
      for(NSUUID *entryUUID in entryUUIDs) {
        KPKEntry *draggedEntry = [document findEntry:entryUUID];
        [draggedEntry moveToGroup:targetGroup];
        [draggedEntry.undoManager setActionName:NSLocalizedString(@"DRAG_ENTRY", "Action title for moving an entry via drag and drop")];
      }
    }
    return YES;
  }
  /* external drop */
  for(KPKEntry *draggedEntry in [self _entriesFromPasteboard:info.draggingPasteboard]) {
    KPKEntry *entry = [draggedEntry copyWithTitle:nil options:kKPKCopyOptionCopyHistory];
    [entry addToGroup:targetGroup];
    [entry.undoManager setActionName:NSLocalizedString(@"DRAG_ENTRY", "Action title for copying an entry via drag and drop to another database")];
  }
  for(KPKGroup *draggedGroup in [self _normalizedGroupsFromPasterboard:info.draggingPasteboard]) {
    KPKGroup *group = [draggedGroup copyWithTitle:nil options:kKPKCopyOptionCopyHistory];
    [group addToGroup:targetGroup];
    [group.undoManager setActionName:NSLocalizedString(@"DRAG_GROUP", "Actiontitle for copying groups via drag and drop to antother database")];
  }
  return YES;
}

- (NSArray<NSUUID *> *)_entryUUIDsFromPasteboard:(NSPasteboard *)pBoard {
  if([pBoard.types containsObject:KPKEntryUUDIUTI]) {
    if([pBoard canReadObjectForClasses:@[NSUUID.class] options:nil]) {
      return [pBoard readObjectsForClasses:@[NSUUID.class] options:nil];
    }
  }
  return @[];
}

- (NSArray<KPKGroup *> *)_normalizedGroupsFromPasterboard:(NSPasteboard *)pBoard {
  if([pBoard.types containsObject:KPKGroupUTI]) {
    if([pBoard canReadObjectForClasses:@[KPKGroup.class] options:nil]) {
      NSArray<KPKGroup *> *groups = [pBoard readObjectsForClasses:@[KPKGroup.class] options:nil];
      return [groups filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        KPKGroup *group = evaluatedObject;
        BOOL isValid = YES;
        for(KPKGroup *otherGroup in groups) {
          if(otherGroup == group) {
            continue;
          }
          if(nil != [otherGroup groupForUUID:group.uuid]) {
            isValid = NO;
            break;
          }
        }
        return isValid;
      }]];
    }
  }
  return @[];
}

- (NSArray<KPKEntry *> *)_entriesFromPasteboard:(NSPasteboard *)pBoard {
  if([pBoard.types containsObject:KPKEntryUTI]) {
    if([pBoard canReadObjectForClasses:@[KPKEntry.class] options:nil]) {
      return [pBoard readObjectsForClasses:@[KPKEntry.class] options:nil];
    }
  }
  return @[];
}

@end
