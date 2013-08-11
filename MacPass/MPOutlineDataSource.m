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
@property (weak) KdbEntry *draggedEntry;

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
  info.animatesToDestination = YES;
  NSDragOperation oprationMask = NSDragOperationMove;
  /*
   If we can support copy on drag, this can be used
   to optain the dragging modifier mask the user presses
   if([info draggingSourceOperationMask] == NSDragOperationCopy) {
   oprationMask = NSDragOperationCopy;
   }
   */
  id targetItem = [item representedObject];
  if(targetItem == nil) {
    return NSDragOperationNone; // no Target
  }
  
  NSPasteboard *pasteBoard = [info draggingPasteboard];
  NSArray *types = [pasteBoard types];
  if([types count] > 1 || [types count] == 0) {
    return NSDragOperationNone; // We cannot work with more than one type
  }
  
  MPDocument *document = [[[outlineView window] windowController] document];
  NSString *draggedType = [types lastObject];
  if([draggedType isEqualToString:MPGroupUTI]) {
    // dragging group
    self.draggedEntry = nil;
  }
  else if([draggedType isEqualToString:MPUUIDUTI]) {
    NSArray *uuids = [pasteBoard readObjectsForClasses:@[[UUID class]] options:nil];
    if([uuids count] != 1) {
      return NSDragOperationNone; // NO entry readable
    }
    self.draggedEntry = [document findEntry:[uuids lastObject]];
  }
  else {
    return NSDragOperationNone; // unkonw type
  }
  
  if(self.draggedGroup && [targetItem isKindOfClass:[MPRootAdapter class]]) {
    return NSDragOperationNone; // Drag over group header
  }
  
  KdbGroup *targetGroup = targetItem;
  BOOL validTarget = YES;
  if(self.draggedGroup) {
    NSLog(@"draggin Group %@", self.draggedGroup.name);
    if( self.draggedGroup.parent == targetGroup ) {
      validTarget &= index != NSOutlineViewDropOnItemIndex;
      validTarget &= index != [self.draggedGroup.parent.groups indexOfObject:self.draggedGroup];
    }
  }
  else if(self.draggedEntry) {
    NSLog(@"draggin Entry %@", self.draggedEntry.title);
    validTarget = self.draggedEntry.parent != targetGroup;
  }
  return validTarget ? oprationMask : NSDragOperationNone;
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
