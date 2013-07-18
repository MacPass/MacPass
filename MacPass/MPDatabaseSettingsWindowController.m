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

#import "HNHRoundedSecureTextField.h"

#import "NSString+Empty.h"

#import "Kdb.h"
#import "Kdb4Node.h"
#import "KdbGroup+MPAdditions.h"

@interface MPDatabaseSettingsWindowController () {
  MPDocument *_document;
}

@property (nonatomic,assign) BOOL trashEnabled;
@property (nonatomic,assign) BOOL showPassword;
@property (nonatomic,assign) BOOL hasValidPasswordOrKey;
@property (nonatomic,weak) NSURL *keyURL;

@end

@implementation MPDatabaseSettingsWindowController

- (id)init {
  return [self initWithDocument:nil];
}

- (id)initWithDocument:(MPDocument *)document {
  self = [super initWithWindowNibName:@"DatabaseSettingsWindow"];
  if(self) {
    _document = document;
    _showPassword = NO;
    _hasValidPasswordOrKey = NO;
  }
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
  
  NSAssert(_document != nil, @"Document needs to be present");
  
  [self.saveButton bind:NSEnabledBinding toObject:self withKeyPath:@"hasValidPasswordOrKey" options:nil];
  [self.cancelButton bind:NSEnabledBinding toObject:self withKeyPath:@"hasValidPasswordOrKey" options:nil];
  
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
    [self _setupDatabase:tree];
    [self _setupProtectionTab:tree];
    [self _setupAdvancedTab:tree];
    [self _setupPasswordTab:tree];
  }
}

- (void)showSettingsTab:(MPDatabaseSettingsTab)tab {
  self.showPassword = NO;
  [self.sectionTabView selectTabViewItemAtIndex:tab];
}

- (void)setShowPassword:(BOOL)showPassword {
  if(_showPassword != showPassword) {
    _showPassword = showPassword;
    
    [self.passwordRepeatTextField setStringValue:@""];
    [self _verifyPasswordAndKey];
  }
}

- (void)setKeyURL:(NSURL *)keyURL {
  _keyURL = keyURL;
  [self _verifyPasswordAndKey];
}

#pragma mark Actions
- (IBAction)clearKey:(id)sender {
  self.keyURL = nil;
}

- (IBAction)generateKey:(id)sender {
}

#pragma makr NSTextFieldDelegate
- (void)controlTextDidChange:(NSNotification *)obj {
  [self _verifyPasswordAndKey];
}

#pragma mark Private Helper
- (void)_verifyPasswordAndKey {
  NSString *password = [self.passwordTextField stringValue];
  NSString *repeat = [self.passwordRepeatTextField stringValue];
  BOOL hasKey = (self.keyURL != nil);
  BOOL keyOk = YES;
  if(hasKey) {
    keyOk = [self.keyURL checkResourceIsReachableAndReturnError:nil];
  }
  BOOL hasPassword = ![password isEmpty];
  BOOL passwordOk = YES;
  if(hasPassword ) {
    passwordOk = [password isEqualToString:repeat] || self.showPassword;
  }
  BOOL hasPasswordOrKey = (hasKey || hasPassword);
  keyOk = hasKey ? keyOk : YES;
  passwordOk = hasPassword ? passwordOk : YES;
  self.hasValidPasswordOrKey = hasPasswordOrKey && passwordOk && keyOk;
  
  if(!hasPasswordOrKey) {
    [self.errorTextField setStringValue:NSLocalizedString(@"ERROR_NO_PASSWORD_OR_KEYFILE", "Missing Key or Password")];
    return; // alldone
  }
  if(!passwordOk && !keyOk ) {
    [self.errorTextField setStringValue:NSLocalizedString(@"ERROR_PASSWORD_MISSMATCH_INVALID_KEYFILE", "Passwords do not match, keyfile is invalid")];
  }
  else if(!passwordOk) {
    [self.errorTextField setStringValue:NSLocalizedString(@"ERROR_PASSWORD_MISSMATCH", "Passwords do not match")];
  }
  else {
    [self.errorTextField setStringValue:NSLocalizedString(@"ERROR_INVALID_KEYFILE", "Keyfile not valid")];
  }
  
}

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
  [self.passwordRepeatTextField setStringValue:[self.passwordRepeatTextField stringValue]];
  self.keyURL = _document.key;
  
  NSDictionary *negateOption = @{ NSValueTransformerNameBindingOption : NSNegateBooleanTransformerName };
  [self.passwordTextField bind:@"showPassword" toObject:self withKeyPath:@"showPassword" options:nil];
  [self.togglePasswordButton bind:NSValueBinding toObject:self withKeyPath:@"showPassword" options:nil];
  [self.passwordRepeatTextField bind:NSEnabledBinding toObject:self withKeyPath:@"showPassword" options:negateOption];
  [self.errorTextField bind:NSHiddenBinding toObject:self withKeyPath:@"hasValidPasswordOrKey" options:nil];
  [self.keyfilePathControl bind:NSValueBinding toObject:self withKeyPath:@"keyURL" options:nil];
  
  [self.passwordRepeatTextField setDelegate:self];
  [self.passwordTextField setDelegate:self];
  
  /* Manually initate the first check */
  [self _verifyPasswordAndKey];
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
