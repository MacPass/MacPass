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
#import "MPSettingsHelper.h"

#import "HNHRoundedTextField.h"
#import "HNHRoundedSecureTextField.h"

#import "NSString+Empty.h"

#import "Kdb.h"
#import "Kdb4Node.h"
#import "KdbGroup+MPAdditions.h"

@interface MPDatabaseSettingsWindowController () {
  MPDocument *_document;
  NSString *_missingFeature;
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
    _missingFeature = NSLocalizedString(@"KDBX_ONLY_FEATURE", "Feature only available in kdbx databases");
  }
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
  
  NSAssert(_document != nil, @"Document needs to be present");
  
  [self.saveButton bind:NSEnabledBinding toObject:self withKeyPath:@"hasValidPasswordOrKey" options:nil];
    
  [self.sectionTabView setDelegate:self];
  
  
  [self update];
}

- (void)setDelegate:(id<MPDatabaseSettingsDelegate>)delegate {
  if(_delegate != delegate) {
    if([delegate conformsToProtocol:@protocol(MPDatabaseSettingsDelegate)]) {
      _delegate = delegate;
    }
    else{
      NSAssert(NO, @"Delegate needs to conform to MPDatabaseSettingsDelegate protocoll");
    }
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
  NSMenuItem *trashMenuItem = [self.selectRecycleBinGroupPopUpButton selectedItem];
  KdbGroup *trashGroup = [trashMenuItem representedObject];
  [_document useGroupAsTrash:trashGroup];
  
  NSMenuItem *templateMenuItem = [self.templateGroupPopUpButton selectedItem];
  KdbGroup *templateGroup = [templateMenuItem representedObject];
  [_document useGroupAsTemplate:templateGroup];
  
  BOOL protectNotes = [self.protectNotesCheckButton state] == NSOnState;
  BOOL protectPassword = [self.protectPasswortCheckButton state] == NSOnState;
  BOOL protectTitle = [self.protectTitleCheckButton state] == NSOnState;
  BOOL protectURL = [self.protectURLCheckButton state] == NSOnState;
  BOOL protectUsername = [self.protectUserNameCheckButton state] == NSOnState;
  
  if(_document.version == MPDatabaseVersion4) {
    _document.treeV4.protectNotes = protectNotes;
    _document.treeV4.protectPassword = protectPassword;
    _document.treeV4.protectTitle = protectTitle;
    _document.treeV4.protectUrl = protectURL;
    _document.treeV4.protectUserName = protectUsername;
    
  }
  else {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:protectNotes forKey:kMPSettingsKeyLegacyHideNotes];
    [defaults setBool:protectPassword forKey:kMPSettingsKeyLegacyHidePassword];
    [defaults setBool:protectTitle forKey:kMPSettingsKeyLegacyHideTitle];
    [defaults setBool:protectURL forKey:kMPSettingsKeyLegacyHideURL];
    [defaults setBool:protectUsername forKey:kMPSettingsKeyLegacyHideUsername];
    [defaults synchronize];
  }
  [self closeDidSave:YES];
}

- (IBAction)cancel:(id)sender {
  [self closeDidSave:NO];
}
- (void)closeDidSave:(BOOL)didSave {
  /* Remove the window first */
  [NSApp endSheet:[self window]];
  [[self window] orderOut:nil];
  
  /* Then notify the delegate */
  if(self.delegate) {
    if(didSave && [self.delegate respondsToSelector:@selector(didSaveDatabaseSettings)]) {
      [self.delegate didSaveDatabaseSettings];
    }
    else if(!didSave && [self.delegate respondsToSelector:@selector(didCancelDatabaseSettings)]) {
      [self.delegate didCancelDatabaseSettings];
    }
  }
}


- (void)update {
  /* Update all stuff that might have changed */
  Kdb4Tree *tree = _document.treeV4;
  [self _setupPasswordTab:tree];
  [self _setupDatabase:tree];
  [self _setupProtectionTab:tree];
  [self _setupAdvancedTab:tree];
  [self _setupTemplatesTab:tree];
}

- (void)showSettingsTab:(MPDatabaseSettingsTab)tab {
  /*
   We need to make sure the window is loaded
   so we just call the the getter and led the loading commence
   */
  if(![self window]) {
    return;
  }
  self.showPassword = NO;
  NSTabViewItem *tabViewItem = [self.sectionTabView tabViewItemAtIndex:tab];
  BOOL canSelectTab = [self tabView:self.sectionTabView shouldSelectTabViewItem:tabViewItem];
  if(!canSelectTab) {
    [self.sectionTabView selectTabViewItemAtIndex:MPDatabaseSettingsTabPassword];
  }
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

#pragma mark NSTextFieldDelegate
- (void)controlTextDidChange:(NSNotification *)obj {
  [self _verifyPasswordAndKey];
}

#pragma mark NSTableViewDelegate
- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem {
  NSUInteger index = [tabView indexOfTabViewItem:tabViewItem];
  switch ((MPDatabaseSettingsTab)index) {
    case MPDatabaseSettingsTabPassword:
    case MPDatabaseSettingsTabDisplay:
      return YES;
      
    case MPDatabaseSettingsTabAdvanced:
    case MPDatabaseSettingsTabGeneral:
    case MPDatabaseSettingsTemplatesTab:
      return (_document.version == MPDatabaseVersion4);
      
    default:
      return NO;
  }
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
  BOOL hasPassword = ![NSString isEmptyString:password];
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
  BOOL isKdbx = (nil != tree);
  [self.databaseDescriptionTextView setEditable:isKdbx];
  [self.databaseNameTextField setEnabled:isKdbx];
  if(isKdbx) {
    [self.databaseNameTextField setStringValue:tree.databaseName];
    [self.databaseDescriptionTextView setString:tree.databaseDescription];
  }
  else {
    [self.databaseNameTextField setStringValue:_missingFeature];
    [self.databaseDescriptionTextView setString:_missingFeature];
  }
}

- (void)_setupProtectionTab:(Kdb4Tree *)tree {
  BOOL isKdbX = (nil != tree);
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  BOOL protectNotes = isKdbX ? tree.protectNotes : [defaults boolForKey:kMPSettingsKeyLegacyHideNotes];
  BOOL protectPassword = isKdbX ? tree.protectPassword : [defaults boolForKey:kMPSettingsKeyLegacyHidePassword];
  BOOL protectTitle = isKdbX ? tree.protectTitle : [defaults boolForKey:kMPSettingsKeyLegacyHideTitle];
  BOOL protectUrl = isKdbX ? tree.protectUrl : [defaults boolForKey:kMPSettingsKeyLegacyHideURL];
  BOOL protectUsername = isKdbX ? tree.protectUserName : [defaults boolForKey:kMPSettingsKeyLegacyHideUsername];
  
  [self.protectNotesCheckButton setState:protectNotes ? NSOnState : NSOffState ];
  [self.protectPasswortCheckButton setState:protectPassword ? NSOnState : NSOffState];
  [self.protectTitleCheckButton setState:protectTitle ? NSOnState : NSOffState];
  [self.protectURLCheckButton setState:protectUrl ? NSOnState : NSOffState];
  [self.protectUserNameCheckButton setState:protectUsername ? NSOnState : NSOffState];
}

- (void)_setupAdvancedTab:(Kdb4Tree *)tree {
  BOOL isKdbX = (nil != tree);
  
  self.trashEnabled = isKdbX ? tree.recycleBinEnabled : NO;
  
  [self.enableRecycleBinCheckButton bind:NSValueBinding toObject:self withKeyPath:@"trashEnabled" options:nil];
  [self.enableRecycleBinCheckButton setEnabled:isKdbX];
  [self.selectRecycleBinGroupPopUpButton bind:NSEnabledBinding toObject:self withKeyPath:@"trashEnabled" options:nil];
  if(isKdbX) {
    [self _updateTrashFolders:tree];
  }
}

- (void)_setupPasswordTab:(Kdb4Tree *)tree {
  [self.passwordTextField setStringValue:_document.password ? _document.password : @""];
  [self.passwordRepeatTextField setStringValue:[self.passwordTextField stringValue]];
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

- (void)_setupTemplatesTab:(Kdb4Tree *)tree {
  if(tree) {
    [self.defaultUsernameTextField setStringValue:tree.defaultUserName];
    [self.defaultUsernameTextField setEditable:YES];
  }
  else {
    [self.defaultUsernameTextField setStringValue:_missingFeature];
    [self.defaultUsernameTextField setEditable:NO];
  }
}

- (void)_updateFirstResponder {
  NSTabViewItem *selected = [self.sectionTabView selectedTabViewItem];
  MPDatabaseSettingsTab tab = [[self.sectionTabView tabViewItems] indexOfObject:selected];
  
  switch(tab) {
    case MPDatabaseSettingsTabAdvanced:
      [[self window] makeFirstResponder:self.databaseNameTextField];
      break;
      
    case MPDatabaseSettingsTabDisplay:
      [[self window] makeFirstResponder:self.protectTitleCheckButton];
      break;
      
    case MPDatabaseSettingsTabGeneral:
      [[self window] makeFirstResponder:self.databaseNameTextField];
      break;
      
    case MPDatabaseSettingsTabPassword:
      [[self window] makeFirstResponder:self.passwordTextField];
      break;
      
    case MPDatabaseSettingsTemplatesTab:
      break;
  }
}

- (void)_updateTrashFolders:(Kdb4Tree *)tree {
  NSMenu *menu = [self _buildTrashTreeMenu:tree];
  [self.selectRecycleBinGroupPopUpButton setMenu:menu];
}

- (void)_updateTemplateGroup:(Kdb4Tree *)tree {
  //
}

- (NSMenu *)_buildTrashTreeMenu:(Kdb4Tree *)tree {
  NSMenu *menu = [self _buildTreeMenu:tree];
  
  NSMenuItem *selectItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"AUTOCREATE_TRASH_FOLDER", @"Menu item for automatic trash creation")
                                                      action:NULL
                                               keyEquivalent:@""];
  [selectItem setEnabled:YES];
  [menu insertItem:selectItem atIndex:0];
  
  return menu;
}

- (NSMenu *)_buildTemplateTreeMenu:(Kdb4Tree *)tree {
  NSMenu *menu = [self _buildTreeMenu:tree];
  
  NSMenuItem *selectItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"NO_TEMPLATE_GROUP", @"Menu item to reset the template groups")
                                                      action:NULL
                                               keyEquivalent:@""];
  [selectItem setEnabled:YES];
  [menu insertItem:selectItem atIndex:0];
  
  return menu;
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
  return menu;
}

@end
