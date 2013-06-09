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

- (void)addEntryUndoable:(KdbEntry *)entry;
- (void)addGroupUndoable:(KdbGroup *)group;
- (void)removeGroupUndoable:(KdbGroup *)group;
- (void)removeEntryUndoable:(KdbEntry *)entry;

- (void)moveToGroupUndoable:(KdbGroup *)group;

@end
