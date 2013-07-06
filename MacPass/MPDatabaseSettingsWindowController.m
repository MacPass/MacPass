//
//  MPDocumentSettingsWindowController.m
//  MacPass
//
//  Created by Michael Starke on 26.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDatabaseSettingsWindowController.h"
#import "MPDocument.h"
#import "MPDocumentWindowController.h"
#import "MPDatabaseVersion.h"
#import "MPIconHelper.h"

#import "Kdb.h"
#import "Kdb4Node.h"
#import "KdbGroup+MPAdditions.h"

@interface MPDatabaseSettingsWindowController () {
  MPDocument *_document;
}

@property (nonatomic,assign) BOOL trashEnabled;

@end

@implementation MPDatabaseSettingsWindowController

- (id)init {
  return [self initWithDocument:nil];
}

- (id)initWithDocument:(MPDocument *)document {
  self = [super initWithWindowNibName:@"DatabaseSettingsWindow"];
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

- (IBAction)save:(id)sender {
  
  /* Protection */
  _document.password = [self.passwordTextField stringValue];
  _document.key = [self.keyfilePathControl URL];

  /* General */
  _document.treeV4.databaseDescription = [self.databaseDescriptionTextView string];
  _document.treeV4.databaseName = [self.databaseNameTextField stringValue];
  
  /* Display */
  
  /* Advanced */
 _document.treeV4.recycleBinEnabled = self.trashEnabled;
  NSMenuItem *menuItem = [self.selectRecycleBinGroupPopUpButton selectedItem];
  KdbGroup *group = [menuItem representedObject];
  [_document useGroupAsTrash:group];
  
  _document.treeV4.protectNotes = [self.protectNotesCheckButton state] == NSOnState;
  _document.treeV4.protectPassword = [self.protectPasswortCheckButton state] == NSOnState;
  _document.treeV4.protectTitle = [self.protectTitleCheckButton state] == NSOnState;
  _document.treeV4.protectUrl = [self.protectURLCheckButton state] == NSOnState;
  _document.treeV4.protectUserName = [self.protectUserNameCheckButton state] == NSOnState;
  
  /* Close to finish */
  [self close:nil];
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

- (void)showSettingsTab:(MPDatabaseSettingsTab)tab {
  [self.sectionTabView selectTabViewItemAtIndex:tab];
}

#pragma mark Actions
- (IBAction)clearKey:(id)sender {
  [self.keyfilePathControl setURL:nil];
}

- (IBAction)generateKey:(id)sender {
}

#pragma mark Private Helper
- (void)_setupDatabase:(Kdb4Tree *)tree {
  [self.databaseNameTextField setStringValue:tree.databaseName];
  [self.databaseDescriptionTextView setString:tree.databaseDescription];
}

- (void)_setupProtectionTab:(Kdb4Tree *)tree {
  [self.protectNotesCheckButton setState:tree.protectNotes ? NSOnState : NSOffState ];
  [self.protectNotesCheckButton setState:tree.protectPassword ? NSOnState : NSOffState];
  [self.protectTitleCheckButton setState:tree.protectTitle ? NSOnState : NSOffState];
  [self.protectURLCheckButton setState:tree.protectUrl ? NSOnState : NSOffState];
  [self.protectUserNameCheckButton setState:tree.protectUserName ? NSOnState : NSOffState];
}

- (void)_setupAdvancedTab:(Kdb4Tree *)tree {
  self.trashEnabled = tree.recycleBinEnabled;
  [self.enableRecycleBinCheckButton bind:NSValueBinding toObject:self withKeyPath:@"trashEnabled" options:nil];
  [self.selectRecycleBinGroupPopUpButton bind:NSEnabledBinding toObject:self withKeyPath:@"trashEnabled" options:nil];
  [self _updateTrashFolders:tree];
}

- (void)_setupPasswordTab:(Kdb4Tree *)tree {
  [self.passwordTextField setStringValue:_document.password ? _document.password : @""];
  [self.keyfilePathControl setURL:_document.key];
}

- (void)_updateTrashFolders:(Kdb4Tree *)tree {
  NSMenu *menu = [self _buildTreeMenu:tree];
  [self.selectRecycleBinGroupPopUpButton setMenu:menu];
}

- (NSMenu *)_buildTreeMenu:(Kdb4Tree *)tree {
  NSMenu *menu = [[NSMenu alloc] init];
  [menu setAutoenablesItems:NO];

  for(Kdb4Group *group in tree.root.groups) {
    NSMenuItem *groupItem = [[NSMenuItem alloc] init];
    [groupItem setImage:group.icon];
    [groupItem setTitle:group.name];
    [groupItem setRepresentedObject:group];
    [groupItem setEnabled:YES];
    if([group.uuid isEqual:tree.recycleBinUuid]) {
      [groupItem setState:NSOnState];
    }
    [menu addItem:groupItem];
  }
  NSMenuItem *selectItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"SELECT_RECYCLEBIN", @"Menu item if no reycleBin is selected") action:NULL keyEquivalent:@""];
  [selectItem setEnabled:YES];
  [menu insertItem:selectItem atIndex:0];
  
  return menu;
}
@end
