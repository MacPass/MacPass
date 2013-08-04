//
//  MPOutlineDataSource.m
//  MacPass
//
//  Created by Michael Starke on 19.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineDataSource.h"
#import "MPDocument.h"
#import "MPConstants.h"
#import "MPRootAdapter.h"

#import "KdbLib.h"
#import "KdbGroup+Undo.h"
#import "KdbEntry+Undo.h"
#import "KdbGroup+MPTreeTools.h"
#import "KdbEntry+MPTreeTools.h"

#import "UUID.h"
#import "UUID+Pasterboard.h"

@interface MPOutlineDataSource ()

@property (weak) KdbGroup *draggedGroup;

@end


@implementation MPOutlineDataSource

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard {
  self.draggedGroup = nil;
  if([items count] == 1) {
    [pasteboard setString:self.draggedGroup.name forType:MPGroupUTI];
    self.draggedGroup = [[items lastObject] representedObject];
    return (nil != self.draggedGroup.parent);
  }
  return NO;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
  /*  info.animatesToDestination = YES;
    NSDragOperation oprationMask = NSDragOperationMove;
    if([info draggingSourceOperationMask] == NSDragOperationCopy) {
      oprationMask = NSDragOperationCopy;
    }
    
    id targetItem = [item representedObject];
    if(targetItem == nil) {
      return NSDragOperationNone; // no Target
    }
    if([targetItem isKindOfClass:[MPRootAdapter class]]) {
      return NSDragOperationNone; // Drag over group header
    }
    KdbGroup *targetGroup = targetItem;
    BOOL validTarget = YES;
    if( self.draggedGroup.parent == targetGroup ) {
      validTarget &= index != NSOutlineViewDropOnItemIndex;
      validTarget &= index != [self.draggedGroup.parent.groups indexOfObject:self.draggedGroup];
    }
    if( validTarget ) {
      return oprationMask;
    }
  }
  NSPasteboard *pasteBoard = [info draggingPasteboard];
  NSArray *items = [pasteBoard pasteboardItems];
  if([items count] > 0) {
    if( index != NSOutlineViewDropOnItemIndex ) {
      [outlineView setDropItem:item dropChildIndex:NSOutlineViewDropOnItemIndex];
    }
    return NSDragOperationMove;
  }*/
  self.draggedGroup = nil;
  return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
  self.draggedGroup = nil;
  /*
   KdbGroup *target = [item representedObject];
  if(self.draggedGroup) {
    BOOL accepted = YES;
    if( self.draggedGroup.parent == target ) {
      accepted &= index != NSOutlineViewDropOnItemIndex;
      accepted &= index != [self.draggedGroup.parent.groups indexOfObject:self.draggedGroup];
    }
    accepted = ![self.draggedGroup isAnchestorOfGroup:target];
    if( accepted ) {
      [self.draggedGroup moveToGroupUndoable:target atIndex:index];
    }
    info.animatesToDestination = !accepted;
    self.draggedGroup = nil;
    return accepted;
  }
  NSPasteboard *pasteBoard = [info draggingPasteboard];
  NSArray *items = [pasteBoard pasteboardItems];
  if([items count] > 0) {
    NSPasteboardItem *item = items[0];
    UUID *uuid = [[UUID alloc] initWithString:[item stringForType:MPPasteBoardType]];
    MPDocument *document = [[[outlineView window] windowController] document];
    KdbGroup *rootGroup = [document root];
    KdbEntry *draggedEntry = [rootGroup entryForUUID:uuid];
    if(draggedEntry) {
      if(draggedEntry.parent != target && index == NSOutlineViewDropOnItemIndex) {
        [draggedEntry moveToGroupUndoable:target atIndex:index];
        return YES;
      }
    }
  }
  */
  return NO;
}
@end
