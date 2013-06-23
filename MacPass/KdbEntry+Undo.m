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
  [self setLastModificationTime:[NSDate date]];
  [self setTitle:title];
}

- (void)setUsernameUndoable:(NSString *)username {
  [[KdbEntry undoManager] registerUndoWithTarget:self selector:@selector(setUsernameUndoable:) object:self.username];
  [[KdbEntry undoManager] setActionName:NSLocalizedString(@"UNDO_SET_USERNAME", "Undo set username")];
  [self setLastModificationTime:[NSDate date]];
  [self setUsername:username];
}

- (void)setPasswordUndoable:(NSString *)password {
  [[KdbEntry undoManager] registerUndoWithTarget:self selector:@selector(setPasswordUndoable:) object:self.password];
  [[KdbEntry undoManager] setActionName:NSLocalizedString(@"UNDO_SET_PASSWORT", "Undo set password")];
  [self setLastModificationTime:[NSDate date]];
  [self setPassword:password];
}

- (void)setUrlUndoable:(NSString *)url {
  [[KdbEntry undoManager] registerUndoWithTarget:self selector:@selector(setUrlUndoable:) object:self.url];
  [[KdbEntry undoManager] setActionName:NSLocalizedString(@"UNDO_SET_URL", "Undo set URL")];
  [self setLastModificationTime:[NSDate date]];
  [self setUrl:url];
}

- (void)setNotesUndoable:(NSString *)notes {
  [[KdbEntry undoManager] registerUndoWithTarget:self selector:@selector(setNotesUndoable:) object:self.notes];
  [[KdbEntry undoManager] setActionName:NSLocalizedString(@"UNDO_SET_NOTES", "Undo set notes")];
  [self setLastModificationTime:[NSDate date]];
  [self setNotes:notes];
}

@end