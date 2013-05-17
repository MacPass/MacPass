//
//  KdbEntry+Undo.m
//  MacPass
//
//  Created by Michael Starke on 12.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbEntry+Undo.h"
#import "KdbGroup+MPAdditions.h"

@implementation KdbEntry (Undo)

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
  NSDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
  [[document undoManager] registerUndoWithTarget:self selector:@selector(setTitleUndoable:) object:self.title];
  [[document undoManager] setActionName:NSLocalizedString(@"UNDO_SET_TITLE", "Undo set title")];
  [self setTitle:title];
}

- (void)setUsernameUndoable:(NSString *)username {
  NSDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
  [[document undoManager] registerUndoWithTarget:self selector:@selector(setUsernameUndoable:) object:self.username];
  [[document undoManager] setActionName:NSLocalizedString(@"UNDO_SET_USERNAME", "Undo set username")];
  [self setUsername:username];
}

- (void)setPasswordUndoable:(NSString *)password {
  NSDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
  [[document undoManager] registerUndoWithTarget:self selector:@selector(setTitleUndoable:) object:self.password];
  [[document undoManager] setActionName:NSLocalizedString(@"UNDO_SET_PASSWORT", "Undo set password")];
  [self setPassword:password];
}

- (void)setUrlUndoable:(NSString *)url {
  NSDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
  [[document undoManager] registerUndoWithTarget:self selector:@selector(setTitleUndoable:) object:self.url];
  [[document undoManager] setActionName:NSLocalizedString(@"UNDO_SET_URL", "Undo set URL")];
  [self setUrl:url];
}

- (void)setNotesUndoable:(NSString *)notes {
  NSDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
  [[document undoManager] registerUndoWithTarget:self selector:@selector(setTitleUndoable:) object:self.notes];
  [[document undoManager] setActionName:NSLocalizedString(@"UNDO_SET_NOTES", "Undo set notes")];
  [self setNotes:notes];
}

- (void)moveToIndexUndoable:(NSNumber *)index {
  if(!self.parent) {
    return;
  }
  NSUInteger iIndex = [index unsignedIntegerValue];
  NSNumber *oldIndex = @([self.parent.entries indexOfObject:self]);
  NSDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
  [[document undoManager] registerUndoWithTarget:self selector:@selector(moveToIndexUndoable:) object:oldIndex];
  [[document undoManager] setActionName:NSLocalizedString(@"UNDO_SET_POSITION", "Undo set entry position")];

  [self.parent moveEntry:self toIndex:iIndex];
}

- (void)moveToGroupUndoable:(KdbGroup *)newGroup {
  if(self.parent == newGroup) {
    return;
  }
  if(!self.parent || !newGroup) {
    return;
  }
  NSDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
  [[document undoManager] registerUndoWithTarget:self selector:@selector(moveToGroupUndoable:) object:self.parent];
  [[document undoManager] setActionName:NSLocalizedString(@"UNDO_MOVE_ENTRY", "Undo move entry to group")];
  [self.parent moveEntry:self toGroup:newGroup];
}
@end