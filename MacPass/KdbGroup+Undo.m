//
//  KdbGroup+Undo.m
//  MacPass
//
//  Created by Michael Starke on 18.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbGroup+Undo.h"
#import "KdbGroup+KVOAdditions.h"
#import "KdbEntry+Undo.h"

#ifndef MPSetActionName
#define MPSetActionName(key, comment) \
if(![[self undoManager] isUndoing]) {\
[[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]];\
}
#endif

NSString *const MPGroupNameUndoableKey = @"nameUndoable";

@implementation KdbGroup (Undo)

- (NSUndoManager *)undoManager {
  return [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
}

- (NSString *)nameUndoable {
  return [self name];
}

- (void)setNameUndoable:(NSString *)newName {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setNameUndoable:) object:self.name];
  MPSetActionName(@"SET_NAME", "Set Name")
  self.name = newName;
}

- (void)deleteUndoable {
  if(!self.parent) {
    return;
  }
  NSUInteger oldIndex = [self.parent.groups indexOfObject:self];
  if(oldIndex == NSNotFound) {
    return; // Inconsistent data
  }
  [[[self undoManager] prepareWithInvocationTarget:self.parent] addGroupUndoable:self atIndex:oldIndex];
  MPSetActionName(@"DELETE_GROUP", "Delete Group")
  [self.parent removeObjectFromGroupsAtIndex:[self.parent.groups indexOfObject:self]];
}

- (void)addGroupUndoable:(KdbGroup *)group atIndex:(NSUInteger)index {
  if(!group) {
    return;
  }
  if(index < [group.groups count]) {
    return; // Wrong index!
  }
  [[[self undoManager] prepareWithInvocationTarget:group] deleteUndoable];
  MPSetActionName(@"ADD_GROUP", "Add Group")
  [self insertObject:group inGroupsAtIndex:index];
}

- (void)addEntryUndoable:(KdbEntry *)entry atIndex:(NSUInteger)index {
  if(!entry) {
    return;
  }
  if(index > [self.entries count]) {
    return; // Wrong index!
  }
  [[[self undoManager] prepareWithInvocationTarget:entry] deleteUndoable];
  MPSetActionName(@"ADD_ENTRY", "Add Entry")
  [self insertObject:entry inEntriesAtIndex:index];
}

- (void)moveToGroupUndoable:(KdbGroup *)group atIndex:(NSUInteger)index {
  if(!self.parent || !group) {
    return; // No target or origin
  }
  NSUInteger oldIndex = [self.parent.groups indexOfObject:self];
  if(index == NSNotFound) {
    return; // We aren't in our parents groups list.
  }
  [[[self undoManager] prepareWithInvocationTarget:self] moveToGroupUndoable:self.parent atIndex:oldIndex];
  MPSetActionName(@"MOVE_GROUP", "Move Group")
  [self.parent removeObjectFromGroupsAtIndex:oldIndex];
  [group insertObject:self inGroupsAtIndex:index];
}

- (void)moveToTrashUndoable:(KdbGroup *)trash atIndex:(NSUInteger)index {
  if(!self.parent || !trash) {
    return; // No target or origin
  }
  NSUInteger oldIndex = [self.parent.groups indexOfObject:self];
  if(index == NSNotFound) {
    return; // We aren't in our parents groups list.
  }
  [[[self undoManager] prepareWithInvocationTarget:self] restoreFromTrashUndoable:self.parent atIndex:oldIndex];
  MPSetActionName(@"MOVE_TO_TRASH", @"Move to Trash")
  [self.parent removeObjectFromGroupsAtIndex:oldIndex];
  [trash insertObject:self inGroupsAtIndex:index];
}

- (void)restoreFromTrashUndoable:(KdbGroup *)group atIndex:(NSUInteger)index {
  if(!self.parent || !group) {
    return; // No target or origin
  }
  NSUInteger oldIndex = [self.parent.groups indexOfObject:self];
  if(index == NSNotFound) {
    return; // We aren't in our parents groups list.
  }
  [[[self undoManager] prepareWithInvocationTarget:self] moveToTrashUndoable:self.parent atIndex:oldIndex];
  MPSetActionName(@"RESTORE_GROUP", "Restore from Trash")
  [self.parent removeObjectFromGroupsAtIndex:oldIndex];
  [group insertObject:self inGroupsAtIndex:index];
}

@end
