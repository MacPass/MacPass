//
//  MPOutlineDataSource.m
//  MacPass
//
//  Created by Michael Starke on 19.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineDataSource.h"
#import "MPDocument.h"
#import "KdbLib.h"
#import "KdbGroup+Undo.h"

NSString *const MPPasteBoardType = @"com.hicknhack.macpass.pasteboard";

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
    KdbGroup *target = [item representedObject];
    if( target == nil) {
      return NSDragOperationNone; // Draggin over root
    }
    BOOL validTarget = YES;
    if( _draggedItem.parent == target ) {
      validTarget &= index != NSOutlineViewDropOnItemIndex;
      validTarget &= index != [_draggedItem.parent.groups indexOfObject:_draggedItem];
    }
    if( validTarget ) {
      return NSDragOperationMove;
    }
  }
  return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
  NSLog(@"Drag %@ to: %@ index: %ld", _draggedItem, [item representedObject], index);
  KdbGroup *target = [item representedObject];
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
@end
