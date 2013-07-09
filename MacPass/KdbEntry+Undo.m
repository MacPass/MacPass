//
//  KdbEntry+Undo.m
//  MacPass
//
//  Created by Michael Starke on 12.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbEntry+Undo.h"
#import "KdbGroup+Undo.h"
#import "KdbGroup+KVOAdditions.h"
#import "KdbGroup+MPTreeTools.h"

NSString *const MPEntryTitleUndoableKey = @"titleUndoable";
NSString *const MPEntryUsernameUndoableKey = @"usernameUndoable";
NSString *const MPEntryPasswordUndoableKey = @"passwordUndoable";
NSString *const MPEntryUrlUndoableKey = @"urlUndoable";
NSString *const MPEntryNotesUndoableKey = @"notesUndoable";

@implementation KdbEntry (Undo)

- (NSUndoManager *)undoManager {
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
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setTitleUndoable:) object:self.title];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_TITLE", "Undo set title")];
  [self setLastModificationTime:[NSDate date]];
  [self setTitle:title];
}

- (void)setUsernameUndoable:(NSString *)username {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setUsernameUndoable:) object:self.username];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_USERNAME", "Undo set username")];
  [self setLastModificationTime:[NSDate date]];
  [self setUsername:username];
}

- (void)setPasswordUndoable:(NSString *)password {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setPasswordUndoable:) object:self.password];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_PASSWORT", "Undo set password")];
  [self setLastModificationTime:[NSDate date]];
  [self setPassword:password];
}

- (void)setUrlUndoable:(NSString *)url {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setUrlUndoable:) object:self.url];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_URL", "Undo set URL")];
  [self setLastModificationTime:[NSDate date]];
  [self setUrl:url];
}

- (void)setNotesUndoable:(NSString *)notes {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setNotesUndoable:) object:self.notes];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_NOTES", "Undo set notes")];
  [self setLastModificationTime:[NSDate date]];
  [self setNotes:notes];
}

- (void)deleteUndoable {
  if(!self.parent) {
    return; // No parent to be removed from
  }
  NSUInteger oldIndex = [self.parent.entries indexOfObject:self];
  if(oldIndex == NSNotFound) {
    return; // We're not in our parents entries list
  }
  [[[self undoManager] prepareWithInvocationTarget:self.parent] addEntryUndoable:self atIndex:oldIndex];
  [[self undoManager] setActionName:@"Delete Entry"];
  [self.parent removeObjectFromEntriesAtIndex:oldIndex];
}

- (void)moveToGroupUndoable:(KdbGroup *)group atIndex:(NSUInteger)index {
  if(!group || !self.parent) {
    return; // Nothing to be moved about
  }
  NSUInteger oldIndex = [self.parent.entries indexOfObject:self];
  if(oldIndex == NSNotFound) {
    return; // Not found in entries of parent!
  }
  [[[self undoManager] prepareWithInvocationTarget:self] moveToGroupUndoable:self.parent atIndex:oldIndex];
  [[self undoManager] setActionName:@"Move Entry"];
  [self.parent removeObjectFromEntriesAtIndex:oldIndex];
  [group insertObject:self inEntriesAtIndex:index];
}
- (void)moveToTrashUndoable:(KdbGroup *)trash atIndex:(NSUInteger)index {
  if(!trash || !self.parent) {
    return; // Nothing to be moved about
  }
  NSUInteger oldIndex = [self.parent.entries indexOfObject:self];
  if(oldIndex == NSNotFound) {
    return; // Not found in entries of parent!
  }
  [[[self undoManager] prepareWithInvocationTarget:self] restoreFromTrashUndoable:self.parent atIndex:oldIndex];
  [[self undoManager] setActionName:@"Trash Entry"];
  [self.parent removeObjectFromEntriesAtIndex:oldIndex];
  [trash insertObject:self inEntriesAtIndex:index];
}

- (void)restoreFromTrashUndoable:(KdbGroup *)group atIndex:(NSUInteger)index {
  if(!group || !self.parent) {
    return; // Nothing to be moved about
  }
  NSUInteger oldIndex = [self.parent.entries indexOfObject:self];
  if(oldIndex == NSNotFound) {
    return; // Not found in entries of parent!
  }
  [[[self undoManager] prepareWithInvocationTarget:self] moveToTrashUndoable:self.parent atIndex:oldIndex];
  [[self undoManager] setActionName:@"Restore Entry"];
  [self.parent removeObjectFromEntriesAtIndex:oldIndex];
  [group insertObject:self inEntriesAtIndex:index];

}

@end