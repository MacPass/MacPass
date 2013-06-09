//
//  KdbEntry+Undo.m
//  MacPass
//
//  Created by Michael Starke on 12.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbEntry+Undo.h"
#import "KdbGroup+MPTreeTools.h"

NSString *const MPEntryTitleUndoableKey = @"titleUndoable";
NSString *const MPEntryUsernameUndoableKey = @"usernameUndoable";
NSString *const MPEntryPasswordUndoableKey = @"passwordUndoable";
NSString *const MPEntryUrlUndoableKey = @"urlUndoable";
NSString *const MPEntryNotesUndoableKey = @"notesUndoable";

@implementation KdbEntry (Undo)

+ (NSUndoManager *)undoManager {
  return [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
}

- (NSString *)titleUndoable {
  return [self title];
}

- (NSString *)usernameUndoable {
  return [self username];
}

- (NSString *)passwordUndoable {
  return [self password];
}

- (NSString *)urlUndoable {
  return [self url];
}

- (NSString *)notesUndoable {
  return [self notes];
}


- (void)setTitleUndoable:(NSString *)title {
  [[KdbEntry undoManager] registerUndoWithTarget:self selector:@selector(setTitleUndoable:) object:self.title];
  [[KdbEntry undoManager] setActionName:NSLocalizedString(@"UNDO_SET_TITLE", "Undo set title")];
  [self setTitle:title];
}

- (void)setUsernameUndoable:(NSString *)username {
  [[KdbEntry undoManager] registerUndoWithTarget:self selector:@selector(setUsernameUndoable:) object:self.username];
  [[KdbEntry undoManager] setActionName:NSLocalizedString(@"UNDO_SET_USERNAME", "Undo set username")];
  [self setUsername:username];
}

- (void)setPasswordUndoable:(NSString *)password {
  [[KdbEntry undoManager] registerUndoWithTarget:self selector:@selector(setPasswordUndoable:) object:self.password];
  [[KdbEntry undoManager] setActionName:NSLocalizedString(@"UNDO_SET_PASSWORT", "Undo set password")];
  [self setPassword:password];
}

- (void)setUrlUndoable:(NSString *)url {
  [[KdbEntry undoManager] registerUndoWithTarget:self selector:@selector(setUrlUndoable:) object:self.url];
  [[KdbEntry undoManager] setActionName:NSLocalizedString(@"UNDO_SET_URL", "Undo set URL")];
  [self setUrl:url];
}

- (void)setNotesUndoable:(NSString *)notes {
  [[KdbEntry undoManager] registerUndoWithTarget:self selector:@selector(setNotesUndoable:) object:self.notes];
  [[KdbEntry undoManager] setActionName:NSLocalizedString(@"UNDO_SET_NOTES", "Undo set notes")];
  [self setNotes:notes];
}

- (void)moveToIndexUndoable:(NSNumber *)index {
  if(!self.parent) {
    return;
  }
  NSUInteger iIndex = [index unsignedIntegerValue];
  NSNumber *oldIndex = @([self.parent.entries indexOfObject:self]);
  [[KdbEntry undoManager] registerUndoWithTarget:self selector:@selector(moveToIndexUndoable:) object:oldIndex];
  [[KdbEntry undoManager] setActionName:NSLocalizedString(@"UNDO_SET_POSITION", "Undo set entry position")];

  [self.parent moveEntry:self toIndex:iIndex];
}

- (void)moveToGroupUndoable:(KdbGroup *)newGroup {
  if(self.parent == newGroup) {
    return;
  }
  if(!self.parent || !newGroup) {
    return;
  }
  [[KdbEntry undoManager] registerUndoWithTarget:self selector:@selector(moveToGroupUndoable:) object:self.parent];
  [[KdbEntry undoManager] setActionName:NSLocalizedString(@"UNDO_MOVE_ENTRY", "Undo move entry to group")];
  [self.parent moveEntry:self toGroup:newGroup];
}
@end