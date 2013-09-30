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

@property (weak) KPKGroup *localDraggedGroup;
@property (weak) KPKEntry *localDraggedEntry;

@end

@implementation MPOutlineDataSource

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard {
  if([items count] == 1) {
    self.localDraggedGroup = nil;  id item = [[items lastObject] representedObject];
    if(![item isKindOfClass:[KPKGroup class]]) {
      return NO;
    }
    KPKGroup *draggedGroup = item;
    [pasteboard writeObjects:@[draggedGroup]];
    return (nil != draggedGroup.parent);
  }
  return NO;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {

  /* Clean up our local search */
  self.localDraggedEntry = nil;
  self.localDraggedGroup = nil;
  
  info.animatesToDestination = YES;
  NSDragOperation operationMask = NSDragOperationMove;
  /*
   If we can support copy on drag, this can be used
   to optain the dragging modifier mask the user presses
   */
  BOOL localCopy = NO;
  if([info draggingSourceOperationMask] == NSDragOperationCopy) {
    operationMask = NSDragOperationCopy;
    localCopy = YES;
  }
  
  
  /* Check if the Target is the root group */
  id targetItem = [item representedObject];
  if( ![targetItem isKindOfClass:[KPKGroup class]] ) {
    return NSDragOperationNone; // Block all unknown types
  }
  
  NSPasteboard *pasteBoard = [info draggingPasteboard];
  KPKGroup *draggedGroup = nil;
  KPKEntry *draggedEntry = nil;
  BOOL couldReadPasteboard = [self _readDataFromPasteboard:pasteBoard group:&draggedGroup entry:&draggedEntry];
  if(!couldReadPasteboard) {
    return NSDragOperationNone;
  }
  
  KPKGroup *targetGroup = targetItem;
  BOOL validTarget = YES;
  MPDocument *document = [[[outlineView window] windowController] document];
  /* Dragging Groups */
  if(draggedGroup) {
    self.localDraggedGroup = [document findGroup:draggedGroup.uuid];
    if( [draggedGroup.uuid isEqual:targetGroup.uuid] ) {
      return NSDragOperationNone; // Groups cannot be moved inside themselves
    }
    if(self.localDraggedGroup) {
      if( self.localDraggedGroup.parent == targetGroup ) {
        validTarget &= index != NSOutlineViewDropOnItemIndex;
        validTarget &= index != [self.localDraggedGroup.parent.groups indexOfObject:self.localDraggedGroup];
      }
      BOOL isAnchesor = [self.localDraggedGroup isAnchestorOfGroup:targetGroup];
      validTarget &= !isAnchesor;
    }
    else {
      /* Copy can always work in this case */
      operationMask = NSDragOperationCopy;
    }
  }
  else if(draggedEntry) {
    self.localDraggedEntry = [document findEntry:draggedEntry.uuid];
    if(self.localDraggedEntry) {
      /* local Copy is always valid regardless of parent */
      validTarget = localCopy ? YES : self.localDraggedEntry.parent != targetGroup;
      [outlineView setDropItem:item dropChildIndex:NSOutlineViewDropOnItemIndex];
    }
    else {
      /* Entry copy is always valid */
      operationMask = NSDragOperationCopy;
    }
  }
  return validTarget ? operationMask : NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
  info.animatesToDestination = YES;
  
  id targetItem = [item representedObject];
  if(![targetItem isKindOfClass:[KPKGroup class]]) {
    return NO; // Wrong
  }
  
  NSPasteboard *pasteBoard = [info draggingPasteboard];
  KPKGroup *draggedGroup = nil;
  KPKEntry *draggedEntry = nil;
  BOOL validPateboard = [self _readDataFromPasteboard:pasteBoard group:&draggedGroup entry:&draggedEntry];
  if(!validPateboard) {
    return NO;
  }
  
  BOOL copyItem = ([info draggingSourceOperationMask] == NSDragOperationCopy);
  
  KPKGroup *targetGroup = (KPKGroup *)targetItem;
  if(draggedGroup) {
    if(copyItem || (nil == self.localDraggedGroup) ) {
      /* Add Copy to title */
      NSString *copyTemplate = NSLocalizedString(@"%@_COPY", "");
      /* If we copy, we need to update the uuid */
      draggedGroup.name = [NSString stringWithFormat:copyTemplate, draggedGroup.name];
      draggedGroup.uuid = [NSUUID UUID];
      [targetGroup addGroup:draggedGroup atIndex:index];
      [targetGroup.undoManager setActionName:NSLocalizedString(@"COPY_GROUP", "")];
      return YES;
    }
    else if(self.localDraggedGroup) {
      /* Simple move */
      [self.localDraggedGroup moveToGroup:targetGroup atIndex:index];
      [self.localDraggedGroup.undoManager setActionName:NSLocalizedString(@"MOVE_GROUP", "")];
      return YES;
    }
    /* Nothing valid */
    return NO;
  }
  else if(draggedEntry) {
    if(copyItem || (nil == self.localDraggedEntry)) {
      /* if we copy, we need to update the uuid */
      NSString *copyTemplate = NSLocalizedString(@"%@_COPY", "");
      draggedEntry.title = [NSString stringWithFormat:copyTemplate, draggedEntry.title];
      draggedEntry.uuid = [NSUUID UUID];
      [targetGroup addEntry:draggedEntry atIndex:index];
      [targetGroup.undoManager setActionName:NSLocalizedString(@"COPY_ENTRY", "")];
      return YES;
    }
    else if(self.localDraggedEntry) {
      [self.localDraggedEntry moveToGroup:targetGroup atIndex:index];
      [self.localDraggedEntry.undoManager setActionName:NSLocalizedString(@"MOVE_ENTRY", "")];
      return YES;
    }
  }
  return NO;
}

- (BOOL)_readDataFromPasteboard:(NSPasteboard *)pasteboard group:(KPKGroup **)group entry:(KPKEntry **)entry;{

  if(entry == NULL || group == NULL) {
    return NO; // Need valid pointers
  }
  /* Cleanup old stuff */
  
  NSArray *types = [pasteboard types];
  if([types count] > 1 || [types count] == 0) {
    return NO;
  }
  
  NSString *draggedType = [types lastObject];
  if([draggedType isEqualToString:KPKGroupUTI]) {
    // dragging group
    NSArray *groups = [pasteboard readObjectsForClasses:@[[KPKGroup class]] options:nil];
    if([groups count] != 1) {
      return NO;
    }
    *group = [groups lastObject];
    return YES;
  }
  else if([draggedType isEqualToString:KPKEntryUTI]) {
    NSArray *entries = [pasteboard readObjectsForClasses:@[[KPKEntry class]] options:nil];
    if([entries count] != 1) {
      return NO; // NO entry readable
    }
    *entry = [entries lastObject];
    return YES;
  }
  return NO;
}

@end
