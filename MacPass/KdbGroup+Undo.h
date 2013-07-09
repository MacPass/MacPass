//
//  KdbGroup+Undo.h
//  MacPass
//
//  Created by Michael Starke on 18.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb.h"

APPKIT_EXTERN NSString *const MPGroupNameUndoableKey;

@interface KdbGroup (Undo)

- (NSUndoManager *)undoManager;

- (NSString *)nameUndoable;
- (void)setNameUndoable:(NSString *)newName;

- (void)deleteUndoable;
- (void)addGroupUndoable:(KdbGroup *)group atIndex:(NSUInteger)index;
- (void)addEntryUndoable:(KdbEntry *)entry atIndex:(NSUInteger)index;
- (void)moveToGroupUndoable:(KdbGroup *)group atIndex:(NSUInteger)index;
- (void)moveToTrashUndoable:(KdbGroup *)trash atIndex:(NSUInteger)index;
- (void)restoreFromTrahsUndoable:(KdbGroup *)group atIndex:(NSUInteger)index;

@end
