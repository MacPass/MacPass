//
//  MPDocumentSettingsWindowController.m
//  MacPass
//
//  Created by Michael Starke on 26.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocumentSettingsWindowController.h"
#import "MPDocument.h"
#import "MPDatabaseVersion.h"
#import "Kdb4Node.h"
#import "Kdb4Tree+Undo.h"

@interface MPDocumentSettingsWindowController () {
  MPDocument *_document;
}

@end

@implementation MPDocumentSettingsWindowController

- (id)init {
  return [self initWithDocument:nil];
}

- (id)initWithDocument:(MPDocument *)document {
  self = [super initWithWindowNibName:@"DocumentSettingsWindow"];
  if(self) {
    _document = document;
  }
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
  NSAssert(_document != nil, @"Document needs to be present");
  Kdb4Tree *tree = _document.treeV4;
  if( tree ) {
    [self _setupDatabase:tree];
    [self _setupProtectionTab:tree];
    [self _setupHistoryTab:tree];
    [self _setupPasswordTab:tree];
  }
  else {
    // Switch to KdbV3 View
  }
}

- (void)saveChanges:(id)sender {
  [NSApp endSheet:[self window]];
  [[self window] orderOut:nil];
}

- (void)_setupDatabase:(Kdb4Tree *)tree {
  [self.databaseNameTextField bind:NSValueBinding toObject:tree withKeyPath:MPTree4DatabaseNameUndoableKey options:nil];
  [self.databaseDescriptionTextView bind:NSValueBinding toObject:tree withKeyPath:MPTree4DatabaseDescriptionUndoableKey options:nil];
}

- (void)_setupProtectionTab:(Kdb4Tree *)tree {
  [self.protectNotesCheckButton bind:NSValueBinding toObject:tree withKeyPath:MPTree4ProtectNotesUndoableKey options:nil];
  [self.protectPasswortCheckButton bind:NSValueBinding toObject:tree withKeyPath:MPTree4ProtectPasswordUndoableKey options:nil];
  [self.protectTitleCheckButton bind:NSValueBinding toObject:tree withKeyPath:MPTree4ProtectTitleUndoableKey options:nil];
  [self.protectURLCheckButton bind:NSValueBinding toObject:tree withKeyPath:MPTree4ProtectUrlUndoableKey options:nil];
  [self.protectUserNameCheckButton bind:NSValueBinding toObject:tree withKeyPath:MPTree4ProtectUsernameUndoableKey options:nil];
}

- (void)_setupHistoryTab:(Kdb4Tree *)tree {
  
}

- (void)_setupPasswordTab:(Kdb4Tree *)tree {
  
}

@end
