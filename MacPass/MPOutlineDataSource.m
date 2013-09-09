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

#import "KPKGroup.h"
#import "KPKEntry.h"
#import "KPKUTIs.h"

#import "NSUUID+KeePassKit.h"

@interface MPOutlineDataSource ()

@property (weak) KPKGroup *draggedGroup;
@property (weak) KPKEntry *draggedEntry;

@end


@implementation MPOutlineDataSource

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard {
  self.draggedGroup = nil;
  if([items count] == 1) {
    id item = [[items lastObject] representedObject];
    if(![item isKindOfClass:[KPKGroup class]]) {
      return NO;
    }
    [pasteboard setString:self.draggedGroup.name forType:KPKGroupUTI];
    self.draggedGroup = item;
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
  
  NSPasteboard *pasteBoard = [info draggingPasteboard];
  NSArray *types = [pasteBoard types];
  if([types count] > 1 || [types count] == 0) {
    return NSDragOperationNone; // We cannot work with more than one type
  }

  id targetItem = [item representedObject];
  if( ![targetItem isKindOfClass:[KPKGroup class]] && ![targetItem isKindOfClass:[KPKEntry class]]) {
    return NSDragOperationNone; // Block all unknown types
  }
  MPDocument *document = [[[outlineView window] windowController] document];
  NSString *draggedType = [types lastObject];
  if([draggedType isEqualToString:KPKGroupUTI]) {
    // dragging group
    self.draggedEntry = nil;
  }
  else if([draggedType isEqualToString:KPKUUIDUTI]) {
    NSArray *uuids = [pasteBoard readObjectsForClasses:@[[NSUUID class]] options:nil];
    if([uuids count] != 1) {
      return NSDragOperationNone; // NO entry readable
    }
    self.draggedGroup = nil;
    self.draggedEntry = [document findEntry:[uuids lastObject]];
  }
  else {
    return NSDragOperationNone; // unkonw type
  }
  
  KPKGroup *targetGroup = targetItem;
  BOOL validTarget = YES;
  if(self.draggedGroup) {
    if( self.draggedGroup == targetGroup ) {
      return NSDragOperationNone; // Groups cannot be moved inside themselves
    }
    if( self.draggedGroup.parent == targetGroup ) {
      validTarget &= index != NSOutlineViewDropOnItemIndex;
      validTarget &= index != [self.draggedGroup.parent.groups indexOfObject:self.draggedGroup];
    }
    BOOL isAnchesor = [self.draggedGroup isAnchestorOfGroup:targetGroup];
    validTarget &= !isAnchesor;
  }
  else if(self.draggedEntry) {
    validTarget = self.draggedEntry.parent != targetGroup;
    [outlineView setDropItem:item dropChildIndex:NSOutlineViewDropOnItemIndex];
  }
  return validTarget ? oprationMask : NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
  info.animatesToDestination = YES;
  NSPasteboard *pasteBoard = [info draggingPasteboard];
  NSArray *types = [pasteBoard types];
  if([types count] > 1 || [types count] == 0) {
    return NO; // We cannot work with more than one type
  }
  
  id targetItem = [item representedObject];
  if(![targetItem isKindOfClass:[KPKGroup class]]) {
    return NO; // Wrong
  }
  
  KPKGroup *targetGroup = (KPKGroup *)targetItem;
  
  NSString *draggedType = [types lastObject];
  if([draggedType isEqualToString:KPKGroupUTI]) {
    [self.draggedGroup moveToGroup:targetGroup atIndex:index];
    [self.draggedGroup.undoManager setActionName:NSLocalizedString(@"MOVE_GROUP", "")];
    return YES;
  }
  else if([draggedType isEqualToString:KPKUUIDUTI]) {
    [self.draggedEntry moveToGroup:targetGroup atIndex:index];
    [self.draggedEntry.undoManager setActionName:NSLocalizedString(@"MOVE_ENTRY", "")];
    return YES;
  }
  return NO;
}
@end
