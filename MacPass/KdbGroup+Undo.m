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
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_NAME", "Undo set name")];
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
  //[[self undoManager] setActionName:NSLocalizedString(@"UNDO_ADD_GROUP", @"Create Group Undo")];
  [[self undoManager] setActionName:@"Add Group"];
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
  [[self undoManager] setActionName:@"Add Entry"];
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
  [[self undoManager] setActionName:@"Move Group"];
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
  [[[self undoManager] prepareWithInvocationTarget:self] restoreFromTrahsUndoable:self.parent atIndex:oldIndex];
  [[self undoManager] setActionName:@"Trash Group"];
  [self.parent removeObjectFromGroupsAtIndex:oldIndex];
  [trash insertObject:self inGroupsAtIndex:index];
}

- (void)restoreFromTrahsUndoable:(KdbGroup *)group atIndex:(NSUInteger)index {
  if(!self.parent || !group) {
    return; // No target or origin
  }
  NSUInteger oldIndex = [self.parent.groups indexOfObject:self];
  if(index == NSNotFound) {
    return; // We aren't in our parents groups list.
  }
  [[[self undoManager] prepareWithInvocationTarget:self] moveToTrashUndoable:self.parent atIndex:oldIndex];
  [[self undoManager] setActionName:@"Restore Group"];
  [self.parent removeObjectFromGroupsAtIndex:oldIndex];
  [group insertObject:self inGroupsAtIndex:index];
}

@end
