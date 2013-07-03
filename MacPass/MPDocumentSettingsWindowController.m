//
//  MPDocumentSettingsWindowController.m
//  MacPass
//
//  Created by Michael Starke on 26.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocumentSettingsWindowController.h"
#import "MPDocument.h"
#import "MPDocumentWindowController.h"
#import "MPDatabaseVersion.h"
#import "MPIconHelper.h"

#import "Kdb.h"
#import "Kdb4Node.h"
#import "KdbGroup+MPAdditions.h"

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
    [self _setupAdvancedTab:tree];
    [self _setupPasswordTab:tree];
  }
  else {
    // Switch to KdbV3 View
  }
}

- (IBAction)close:(id)sender {
  [NSApp endSheet:[self window]];
  [[self window] orderOut:nil];
}

- (void)update {
  /* Update all stuff that might have changed */
  Kdb4Tree *tree = _document.treeV4;
  if(tree) {
    [self _updateTrashFolders:tree];
  }
}

#pragma mark Private Helper
- (void)_setupDatabase:(Kdb4Tree *)tree {
  [self.databaseNameTextField bind:NSValueBinding toObject:tree withKeyPath:@"databaseName" options:nil];
  [self.databaseDescriptionTextView bind:NSValueBinding toObject:tree withKeyPath:@"databaseDescription" options:nil];
}

- (void)_setupProtectionTab:(Kdb4Tree *)tree {
  [self.protectNotesCheckButton bind:NSValueBinding toObject:tree withKeyPath:@"protectNotes" options:nil];
  [self.protectPasswortCheckButton bind:NSValueBinding toObject:tree withKeyPath:@"protectPassword" options:nil];
  [self.protectTitleCheckButton bind:NSValueBinding toObject:tree withKeyPath:@"protectTitle" options:nil];
  [self.protectURLCheckButton bind:NSValueBinding toObject:tree withKeyPath:@"protectUrl" options:nil];
  [self.protectUserNameCheckButton bind:NSValueBinding toObject:tree withKeyPath:@"protectUserName" options:nil];
}

- (void)_setupAdvancedTab:(Kdb4Tree *)tree {
  [self.enableRecycleBinCheckButton bind:NSValueBinding toObject:tree withKeyPath:@"recycleBinEnabled" options:nil];
  [self.selectRecycleBinGroupPopUpButton bind:NSEnabledBinding toObject:tree withKeyPath:@"recycleBinEnabled" options:nil];
  [self _updateTrashFolders:tree];
}

- (void)_setupPasswordTab:(Kdb4Tree *)tree {
  
}


- (void)_didSelectTrashFolder:(id)sender {
  NSMenuItem *menuItem = sender;
  /* if we do not get a group, use nil to reset the trash */
  KdbGroup *group = [menuItem representedObject];
  [_document useGroupAsTrash:group];
}

- (void)_updateTrashFolders:(Kdb4Tree *)tree {
  NSMenu *menu = [self _buildTreeMenu:tree];
  [self.selectRecycleBinGroupPopUpButton setMenu:menu];
}

- (NSMenu *)_buildTreeMenu:(Kdb4Tree *)tree {
  NSMenu *menu = [[NSMenu alloc] init];

  for(Kdb4Group *group in tree.root.groups) {
    NSMenuItem *groupItem = [[NSMenuItem alloc] init];
    [groupItem setImage:group.icon];
    [groupItem setTitle:group.name];
    [groupItem setAction:@selector(_didSelectTrashFolder:)];
    [groupItem setTarget:self];
    [groupItem setRepresentedObject:group];
    if([group.uuid isEqual:tree.recycleBinUuid]) {
      [groupItem setState:NSOnState];
    }
    [menu addItem:groupItem];
    [groupItem release];
  }
  NSMenuItem *selectItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"SELECT_RECYCLEBIN", @"Menu item if no reycleBin is selected") action:NULL keyEquivalent:@""];
  [selectItem setAction:@selector(_didSelectTrashFolder:)];
  [selectItem setTarget:self];
  [menu insertItem:selectItem atIndex:0];
  [selectItem release];
  
  return [menu autorelease];
}
@end
