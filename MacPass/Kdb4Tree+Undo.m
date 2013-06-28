//
//  Kdb4Tree+Undo.m
//  MacPass
//
//  Created by Michael Starke on 27.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb4Tree+Undo.h"

NSString *const MPTree4DatabaseNameUndoableKey            = @"databaseNameUndoable";
NSString *const MPTree4DatabaseDescriptionUndoableKey     = @"databaseDescriptionUndoable";
NSString *const MPTree4DatabaseDefaultUsernameUndoableKey = @"defaultUserNameUndoable";

NSString *const MPTree4ProtectNotesUndoableKey            = @"protectNotesUndoable";
NSString *const MPTree4ProtectPasswordUndoableKey         = @"protectPasswordUndoable";
NSString *const MPTree4ProtectTitleUndoableKey            = @"protectTitleUndoable";
NSString *const MPTree4ProtectUrlUndoableKey              = @"protectUrlUndoable";
NSString *const MPTree4ProtectUsernameUndoableKey         = @"protectUserNameUndoable";

@implementation Kdb4Tree (Undo)

- (NSUndoManager *)undoManager {
  return [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
}


- (NSString *)databaseDescriptionUndoable {
  return self.databaseDescription;
}

- (NSString *)databaseNameUndoable {
  return  self.databaseName;
}


- (NSString *)defaultUserNameUndoable {
  return self.defaultUserName;
}

- (void)setDatabaseDescriptionUndoable:(NSString *)databaseDescription {
  if(![self.databaseDescription isEqualToString:databaseDescription]) {
    [[self undoManager] registerUndoWithTarget:self selector:@selector(setDatabaseDescriptionUndoable:) object:self.databaseDescription];
    [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_DATABASE_DESCRIPTION", @"Undo edit databse description")];
    self.databaseDescriptionChanged = [NSDate date];
    self.databaseDescription = databaseDescription;
  }
}

- (void)setDatabaseNameUndoable:(NSString *)databaseName {
  if(![self.databaseName isEqualToString:databaseName]) {
    [[self undoManager] registerUndoWithTarget:self selector:@selector(setDatabaseNameUndoable:) object:self.databaseName];
    [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_DATABASE_NAME", @"Undo edit database name")];
    self.databaseName = databaseName;
    self.databaseNameChanged = [NSDate date];
  }
}

- (void)setDefaultUserNameUndoable:(NSString *)defaultUserName {
  if(![self.defaultUserName isEqualToString:defaultUserName]) {
    [[self undoManager] registerUndoWithTarget:self selector:@selector(setDefaultUserNameUndoable:) object:self.defaultUserName];
    [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_DEFAULT_USERNAME", @"Undo edit default username")];
    self.defaultUserName = defaultUserName;
    self.defaultUserNameChanged = [NSDate date];
  }
}

- (BOOL)protectNotesUndoable {
  return self.protectNotes;
}

- (BOOL)protectPasswordUndoable {
  return self.protectPassword;
}

- (BOOL)protectTitleUndoable {
  return self.protectTitle;
}

- (BOOL)protectUrlUndoable {
  return self.protectUrl;
}

- (BOOL)protectUserNameUndoable {
  return self.protectUserName;
}

- (void)setProtectNotesUndoable:(BOOL)protectNotes {
  if(self.protectNotes != protectNotes) {
    [[[self undoManager] prepareWithInvocationTarget:self] setProtectNotesUndoable:self.protectNotes];
    [[self undoManager] setActionName:NSLocalizedString(@"UNOD_SET_PROTECT_NOTES", @"")];
    self.protectNotes = protectNotes;
  }
}

- (void)setProtectPasswordUndoable:(BOOL)protectPassword {
  if(self.protectPassword != protectPassword) {
    [[[self undoManager] prepareWithInvocationTarget:self] setProtectPasswordUndoable:self.protectPassword];
    [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_PROTECT_PASSWORD", @"")];
    self.protectPassword = protectPassword;
  }
}

- (void)setProtectTitleUndoable:(BOOL)protectTitle {
  if(self.protectTitle != protectTitle) {
    [[[self undoManager] prepareWithInvocationTarget:self] setProtectTitleUndoable:self.protectPassword];
    [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_PROTECT_TITLE", @"")];
    self.protectTitle = protectTitle;
  }
}

- (void)setProtectUrlUndoable:(BOOL)protectUrl {
  if(self.protectUrl != protectUrl) {
    [[[self undoManager] prepareWithInvocationTarget:self] setProtectUrlUndoable:self.protectUrl];
    [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_PROTECT_URL", @"")];
    self.protectUrl = protectUrl;
  }
}

- (void)setProtectUserNameUndoable:(BOOL)protectUserName {
  if(self.protectUserName != protectUserName) {
    [[[self undoManager] prepareWithInvocationTarget:self] setProtectUserNameUndoable:self.protectUserName];
    [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_PROTECT_USERNAME", @"")];
    self.protectUserName = protectUserName;
  }
}
@end
