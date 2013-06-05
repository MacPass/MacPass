//
//  KdbGroup+Undo.m
//  MacPass
//
//  Created by Michael Starke on 18.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbGroup+Undo.h"

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
  [self addEntry:entry];
}

- (void)addGroupUndoable:(KdbGroup *)group {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(removeGroupUndoable:) object:group];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_ADD_GROUP", @"Create Group Undo")];
  [self addGroup:group];
}

- (void)removeEntryUndoable:(KdbEntry *)entry {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(addEntryUndoable:) object:entry];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_DELETE_ENTRY", "Undo deleting of entry")];
  [self removeEntry:entry];
}

- (void)removeGroupUndoable:(KdbGroup *)group {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(addGroupUndoable:) object:group];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_DELETE_GROUP", @"Create Group Undo")];
  [group.parent removeGroup:group];
}
@end
