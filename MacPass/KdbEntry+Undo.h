//
//  KdbEntry+Undo.h
//  MacPass
//
//  Created by Michael Starke on 12.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb.h"

@interface KdbEntry (Undo)

+ (NSUndoManager *)undoManager;

- (NSString *)titleUndoable;
- (NSString *)usernameUndoable;
- (NSString *)passwordUndoable;
- (NSString *)urlUndoable;
- (NSString *)notesUndoable;

- (void)setTitleUndoable:(NSString *)title;
- (void)setUsernameUndoable:(NSString *)username;
- (void)setPasswordUndoable:(NSString *)password;
- (void)setUrlUndoable:(NSString *)url;
- (void)setNotesUndoable:(NSString *)notes;

- (void)moveToIndexUndoable:(NSNumber *)index;
- (void)moveToGroupUndoable:(KdbGroup *)newGroup;

@end
