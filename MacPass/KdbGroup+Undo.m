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
  
  if(![[self undoManager] isUndoing]) {
    [[self undoManager] setActionName:NSLocalizedString(@"SET_NAME", "Set Name")];
  }
  
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

  if(![[self undoManager] isUndoing]) {
    [[self undoManager] setActionName:NSLocalizedString(@"DELETE_GROUP", "Delete Group")];
  }

  [self.parent removeObjectFromGroupsAtIndex:oldIndex];
}

- (void)addGroupUndoable:(KdbGroup *)group atIndex:(NSUInteger)index {
  if(!group) {
    return;
  }
  
  [[[self undoManager] prepareWithInvocationTarget:group] deleteUndoable];
  
  if(![[self undoManager] isUndoing]) {
    [[self undoManager] setActionName:NSLocalizedString(@"ADD_GROUP", "Add Group")];
  }
  
  index = MIN(index, [group.groups count]);
  [self insertObject:group inGroupsAtIndex:index];
}

- (void)addEntryUndoable:(KdbEntry *)entry atIndex:(NSUInteger)index {
  if(!entry) {
    return;
  }
  index = MIN(index, [self.entries count]);
  [[[self undoManager] prepareWithInvocationTarget:entry] deleteUndoable];
  
  if(![[self undoManager] isUndoing]) {
    [[self undoManager] setActionName:NSLocalizedString(@"ADD_ENTRY", "Add Entry")];
  }
  
  [self insertObject:entry inEntriesAtIndex:index];
}

- (void)moveToGroupUndoable:(KdbGroup *)group atIndex:(NSUInteger)index {
  [self _moveToGroup:group atIndex:index actionName:NSLocalizedString(@"MOVE_GROUP", "Move Group" )];
}

- (void)moveToTrashUndoable:(KdbGroup *)trash atIndex:(NSUInteger)index {
  [self _moveToGroup:trash atIndex:index actionName:NSLocalizedString(@"TRASH_GROUP", "Move Group to Trash")];
}

- (void)_moveToGroup:(KdbGroup *)group atIndex:(NSUInteger)index actionName:(NSString *)actionName {
  if(!self.parent || !group) {
    return; // No target or origin
  }
  NSUInteger oldIndex = [self.parent.groups indexOfObject:self];
  if(oldIndex == NSNotFound) {
    return; // We aren't in our parents groups list.
  }
  [[[self undoManager] prepareWithInvocationTarget:self] moveToGroupUndoable:self.parent atIndex:oldIndex];
  
  if(![[self undoManager] isUndoing]) {
    [[self undoManager] setActionName:actionName];
  }
  
  [self.parent removeObjectFromGroupsAtIndex:oldIndex];
  index = MIN(index, [group.groups count]);
  [group insertObject:self inGroupsAtIndex:index];
}

@end
