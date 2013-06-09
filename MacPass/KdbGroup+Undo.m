//
//  KdbGroup+Undo.m
//  MacPass
//
//  Created by Michael Starke on 18.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbGroup+Undo.h"
#import "KdbGroup+KVOAdditions.h"

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

- (void)addEntryUndoable:(KdbEntry *)entry {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(removeEntryUndoable:) object:entry];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_ADD_ENTRY", "Undo adding of entry")];
  [self insertObject:entry inEntriesAtIndex:[entries count]];
}

- (void)addGroupUndoable:(KdbGroup *)group {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(removeGroupUndoable:) object:group];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_ADD_GROUP", @"Create Group Undo")];
  [self insertObject:group inGroupsAtIndex:[groups count]];
}

- (void)removeEntryUndoable:(KdbEntry *)entry {
  NSInteger index = [entries indexOfObject:entry];
  if(NSNotFound == index) {
    return; // No object found;
  }
  [[self undoManager] registerUndoWithTarget:self selector:@selector(addEntryUndoable:) object:entry];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_DELETE_ENTRY", "Undo deleting of entry")];
  [self removeObjectFromEntriesAtIndex:index];
}

- (void)removeGroupUndoable:(KdbGroup *)group {
  NSInteger index = [group.parent.groups indexOfObject:group];
  if(NSNotFound == index) {
    return; // No object found
  }
  [[self undoManager] registerUndoWithTarget:self selector:@selector(addGroupUndoable:) object:group];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_DELETE_GROUP", @"Create Group Undo")];
  [group.parent removeObjectFromGroupsAtIndex:index];
}

- (void)moveToGroupUndoable:(KdbGroup *)group {
  NSInteger index = [self.parent.groups indexOfObject:self];
  if(NSNotFound == index) {
    return; // No object found
  }
  [[self undoManager] registerUndoWithTarget:self selector:@selector(moveToGroupUndoable:) object:self.parent];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_MOVE_GROUP", @"Move Group Undo")];
  [self.parent removeObjectFromGroupsAtIndex:index];
  [group insertObject:self inGroupsAtIndex:[group.groups count]];
}


@end
