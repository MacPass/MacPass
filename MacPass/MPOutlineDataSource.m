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
#import "KdbGroup+MPTreeTools.h"
#import "KdbEntry+MPTreeTools.h"


#import "UUID.h"

@implementation MPOutlineDataSource


- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard {
  [_draggedItem release];
  _draggedItem = nil;
  [pasteboard setString:@"Weee" forType:MPPasteBoardType];
  if([items count] == 1) {
    _draggedItem = [[[items lastObject] representedObject] retain];
    return (nil != _draggedItem.parent);
  }
  return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
  if(_draggedItem) {
    info.animatesToDestination = YES;
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
    if( _draggedItem.parent == targetGroup ) {
      validTarget &= index != NSOutlineViewDropOnItemIndex;
      validTarget &= index != [_draggedItem.parent.groups indexOfObject:_draggedItem];
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
  }
  return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
  KdbGroup *target = [item representedObject];
  if(_draggedItem) {
    BOOL accepted = YES;
    if( _draggedItem.parent == target ) {
      accepted &= index != NSOutlineViewDropOnItemIndex;
      accepted &= index != [_draggedItem.parent.groups indexOfObject:_draggedItem];
    }
    MPDocument *document = [[[outlineView window] windowController] document];
    accepted = [document group:_draggedItem isMoveableToGroup:target];
    if( accepted ) {
      [document moveGroup:_draggedItem toGroup:target index:index];
    }
    info.animatesToDestination = !accepted;
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
    [uuid release];
    if(draggedEntry) {
      if(draggedEntry.parent != target && index == NSOutlineViewDropOnItemIndex) {
        [document moveEntry:draggedEntry toGroup:target index:index];
        return YES;
      }
    }
  }
  return NO;
}
@end
