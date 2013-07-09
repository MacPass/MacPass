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

#ifndef MPSetActionName
#define MPSetActionName(key, comment) \
if(![[self undoManager] isUndoing]) {\
  [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]];\
}
#endif

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
  MPSetActionName(@"SET_TITLE", "Set Title");
  [self setLastModificationTime:[NSDate date]];
  [self setTitle:title];
}

- (void)setUsernameUndoable:(NSString *)username {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setUsernameUndoable:) object:self.username];
  MPSetActionName(@"SET_USERNAME", "Undo set username");
  [self setLastModificationTime:[NSDate date]];
  [self setUsername:username];
}

- (void)setPasswordUndoable:(NSString *)password {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setPasswordUndoable:) object:self.password];
  MPSetActionName(@"SET_PASSWORT", "Undo set password");
  [self setLastModificationTime:[NSDate date]];
  [self setPassword:password];
}

- (void)setUrlUndoable:(NSString *)url {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setUrlUndoable:) object:self.url];
  MPSetActionName(@"SET_URL", "Undo set URL");
  [self setLastModificationTime:[NSDate date]];
  [self setUrl:url];
}

- (void)setNotesUndoable:(NSString *)notes {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setNotesUndoable:) object:self.notes];
  MPSetActionName(@"SET_NOTES", "Set Notes");
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
  MPSetActionName(@"DELETE_ENTRY", "Delete Entry");
  [[NSNotificationCenter defaultCenter] postNotificationName:@"" object:self userInfo:nil];
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
  MPSetActionName(@"MOVE_ENTRY", "Move Entry")
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
  MPSetActionName(@"MOVE_ENTRY_TO_TRASH", "Move Entryo to Trash")
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
  MPSetActionName(@"RESTORE_ENTRY", "Restore Entry from Trash")
  [self.parent removeObjectFromEntriesAtIndex:oldIndex];
  [group insertObject:self inEntriesAtIndex:index];

}

@end