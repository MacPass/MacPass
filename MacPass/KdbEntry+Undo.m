//
//  KdbEntry+Undo.m
//  MacPass
//
//  Created by Michael Starke on 12.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbEntry+Undo.h"

#import "Kdb4Node.h"
#import "KdbGroup+Undo.h"
#import "KdbGroup+KVOAdditions.h"
#import "KdbGroup+MPTreeTools.h"

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
  MPSetActionName(@"SET_TITLE", "");
  
  [self _touchModifcationDate];
  [self setTitle:title];
}

- (void)setUsernameUndoable:(NSString *)username {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setUsernameUndoable:) object:self.username];
  MPSetActionName(@"SET_USERNAME", "");
 
  [self _touchModifcationDate];
  [self setUsername:username];
}

- (void)setPasswordUndoable:(NSString *)password {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setPasswordUndoable:) object:self.password];
  MPSetActionName(@"SET_PASSWORT", "Undo set password");
  
  [self _touchModifcationDate];
  [self setPassword:password];
}

- (void)setUrlUndoable:(NSString *)url {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setUrlUndoable:) object:self.url];
  MPSetActionName(@"SET_URL", "Undo set URL");
  
  [self _touchModifcationDate];
  [self setUrl:url];
}

- (void)setNotesUndoable:(NSString *)notes {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setNotesUndoable:) object:self.notes];
  MPSetActionName(@"SET_NOTES", "Set Notes");
  
  [self _touchModifcationDate];
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
  
  MPSetActionName(@"DELETE_ENTRY", "");
  
  //[[NSNotificationCenter defaultCenter] postNotificationName:@"" object:self userInfo:nil];
  [self.parent removeObjectFromEntriesAtIndex:oldIndex];
}

- (void)moveToGroupUndoable:(KdbGroup *)group atIndex:(NSUInteger)index {
  [self _moveToGroup:group atIndex:index actionName:NSLocalizedString(@"MOVE_ENTRY", "Move Group")];
}

- (void)moveToTrashUndoable:(KdbGroup *)trash atIndex:(NSUInteger)index {
  [self _moveToGroup:trash atIndex:index actionName:NSLocalizedString(@"TRASH_ENTRY", "Move Entry to Trash")];
}

- (void)_moveToGroup:(KdbGroup *)group atIndex:(NSUInteger)index actionName:(NSString *)name {
  if(!group || !self.parent) {
    return; // Nothing to be moved about
  }
  NSUInteger oldIndex = [self.parent.entries indexOfObject:self];
  if(oldIndex == NSNotFound) {
    return; // Not found in entries of parent!
  }
  [[[self undoManager] prepareWithInvocationTarget:self] _moveToGroup:self.parent atIndex:oldIndex actionName:name];
  
  MPSetActionName(name, "");
  
  [self.parent removeObjectFromEntriesAtIndex:oldIndex];
  // Old indices might be wrong, correct them if necessary
  index = MIN(index, [group.entries count]);
  [group insertObject:self inEntriesAtIndex:index];
  if([self respondsToSelector:@selector(setLocationChanged:)]) {
    id entry = self;
    [entry setLocationChanged:[NSDate date]];
  }
}

- (void)_touchModifcationDate {
  self.lastModificationTime = [NSDate date];
}

@end