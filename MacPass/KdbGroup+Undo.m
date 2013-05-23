//
//  KdbGroup+Undo.m
//  MacPass
//
//  Created by Michael Starke on 18.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbGroup+Undo.h"

@implementation KdbGroup (Undo)

+ (NSUndoManager *)undoManager {
  return [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
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
