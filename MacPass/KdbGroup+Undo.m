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

+ (NSUndoManager *)undoManager {
  return [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
}

- (NSString *)nameUndoable {
  return [self name];
}

- (void)setNameUndoable:(NSString *)newName {
  [[KdbGroup undoManager] registerUndoWithTarget:self selector:@selector(setNameUndoable:) object:self.name];
  [[KdbGroup undoManager] setActionName:NSLocalizedString(@"UNDO_SET_NAME", "Undo set name")];
  self.name = newName;
}

- (void)removeEntryUndoable:(KdbEntry *)entry {
  [[KdbGroup undoManager] registerUndoWithTarget:self selector:@selector(addEntryUndoable:) object:entry];
  [[KdbGroup undoManager] setActionName:NSLocalizedString(@"UNDO_DELETE_ENTRY", "Undo deleting of entry")];
  [self removeEntry:entry];
}

- (void)addEntryUndoable:(KdbEntry *)entry {
  [[KdbGroup undoManager] registerUndoWithTarget:self selector:@selector(removeEntryUndoable:) object:entry];
  [[KdbGroup undoManager] setActionName:NSLocalizedString(@"UNDO_ADD_ENTRY", "Undo adding of entry")];
  [self addEntry:entry];
}

@end
