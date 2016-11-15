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
#import "MPNumericalInputFormatter.h"

#import "KeePassKit/KeePassKit.h"

#import "HNHUi/HNHUi.h"

#import "KPKNode+IconImage.h"

@interface MPDatabaseSettingsWindowController () {
  NSString *_missingFeature;
}
@end

@implementation MPDatabaseSettingsWindowController

- (NSString *)windowNibName {
  return @"DatabaseSettingsWindow";
}

- (id)initWithWindow:(NSWindow *)window {
  self = [super initWithWindow:window];
  if(self) {
    _missingFeature = NSLocalizedString(@"KDBX_ONLY_FEATURE", "Feature only available in kdbx databases");
  }
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
  
  NSAssert(self.document != nil, @"Document needs to be present");
    
  self.sectionTabView.delegate = self;
  self.AESEncryptionRoundsTextField.formatter = [[MPNumericalInputFormatter alloc] init];

  NSMenu *kdfMenu = [[NSMenu alloc] init];
  NSArray *keyderivations = [KPKKeyDerivation availableKeyDerivations];
  for(KPKKeyDerivation *kd in keyderivations) {
    [kdfMenu addItemWithTitle:kd.name action:NULL keyEquivalent:@""];
    kdfMenu.itemArray.lastObject.representedObject = kd.uuid;
  }
  self.keyDerivationPopupButton.menu = kdfMenu;
  self.keyDerivationPopupButton.target = self;
  self.keyDerivationPopupButton.action = @selector(selectKeyDerivation:);
  
  NSMenu *cipherMenu = [[NSMenu alloc] init];
  NSArray *ciphers = [KPKCipher availableCiphers];
  for(KPKCipher *cipher in ciphers) {
    [cipherMenu addItemWithTitle:cipher.name action:NULL keyEquivalent:@""];
    cipherMenu.itemArray.lastObject.representedObject = cipher.uuid;
  }
  self.encryptionPopupButton.menu = cipherMenu;
  self.keyDerivationSettingsTabView.tabViewItems[0].identifier = [KPKAESKeyDerivation uuid];
  self.keyDerivationSettingsTabView.tabViewItems[1].identifier = [KPKArgon2KeyDerivation uuid];
}

#pragma mark Actions

- (IBAction)selectKeyDerivation:(id)sender {
  NSUUID *uuid = self.keyDerivationPopupButton.selectedItem.representedObject;
  [self.keyDerivationSettingsTabView selectTabViewItemWithIdentifier:uuid];
}

- (IBAction)save:(id)sender {
  /* General */
  KPKMetaData *metaData = ((MPDocument *)self.document).tree.metaData;
  metaData.databaseDescription = self.databaseDescriptionTextView.string;
  metaData.databaseName = self.databaseNameTextField.stringValue;

  NSInteger compressionIndex = self.databaseCompressionPopupButton.indexOfSelectedItem;
  if(compressionIndex >= KPKCompressionNone && compressionIndex < KPKCompressionCount) {
    metaData.compressionAlgorithm = (uint32_t)compressionIndex;
  }
  NSColor *databaseColor = self.databaseColorColorWell.color;
  if([databaseColor isEqual:[NSColor clearColor]]) {
    metaData.color = nil;
  }
  else {
    metaData.color = databaseColor;
  }
    
  /* Advanced */
  metaData.useTrash = HNHUIBoolForState(self.enableTrashCheckButton.state);
  NSMenuItem *trashMenuItem = self.selectTrashGoupPopUpButton.selectedItem;
  KPKGroup *trashGroup = trashMenuItem.representedObject;
  ((MPDocument *)self.document).tree.trash  = trashGroup;
  
  NSMenuItem *templateMenuItem = self.templateGroupPopUpButton.selectedItem;
  KPKGroup *templateGroup = templateMenuItem.representedObject;
  ((MPDocument *)self.document).templates = templateGroup;
  
  
  BOOL enforceMasterKeyChange = HNHUIBoolForState(self.enforceKeyChangeCheckButton.state);
  BOOL recommendMasterKeyChange = HNHUIBoolForState(self.recommendKeyChangeCheckButton.state);
  
  enforceMasterKeyChange &= (self.enforceKeyChangeIntervalTextField.stringValue.length != 0);
  recommendMasterKeyChange &= (self.recommendKeyChangeIntervalTextField.stringValue.length != 0);
  
  NSInteger enfoceInterval = self.enforceKeyChangeIntervalTextField.integerValue;
  NSInteger recommendInterval = self.recommendKeyChangeIntervalTextField.integerValue;

  metaData.masterKeyChangeEnforcementInterval = enforceMasterKeyChange ? enfoceInterval : -1;
  metaData.masterKeyChangeRecommendationInterval = recommendMasterKeyChange ? recommendInterval : -1;
  
  /* Security */
  
  metaData.defaultUserName = self.defaultUsernameTextField.stringValue;

  /* fixme! */
  metaData.keyDerivationParameters = @{ KPKAESRoundsOption : [[KPKNumber alloc] initWithUnsignedInteger64: MAX(0,self.AESEncryptionRoundsTextField.integerValue)]};
  
  /* Register an action to enable promts when user cloeses without saving */
  [self.document updateChangeCount:NSChangeDone];
  [self close:nil];
}

- (IBAction)close:(id)sender {
  [self dismissSheet:0];
}

- (IBAction)benchmarkRounds:(id)sender {
  self.createKeyDerivationParametersButton.enabled = NO;
  [KPKAESKeyDerivation parametersForDelay:1 completionHandler:^(NSDictionary * _Nonnull options) {
    self.AESEncryptionRoundsTextField.integerValue = [options[KPKAESRoundsOption] unsignedInteger64Value];
    self.createKeyDerivationParametersButton.enabled = YES;
  }];
}

- (void)updateView {
  if(!self.isDirty) {
    return;
  }
  if(!self.document) {
    return; // no document, just leave
  }
  /* Update all stuff that might have changed */
  KPKMetaData *metaData = ((MPDocument *)self.document).tree.metaData;
  [self _setupDatabaseTab:metaData];
  [self _setupSecurityTab:metaData];
  [self _setupAdvancedTab:((MPDocument *)self.document).tree];
  self.isDirty = NO;
}

- (void)showSettingsTab:(MPDatabaseSettingsTab)tab {
  /*
   We need to make sure the window is loaded
   so we just call the the getter and let the loading commence
   */
  if(![self window]) {
    return;
  }
  [self.sectionTabView selectTabViewItemAtIndex:tab];
}

#pragma mark NSTableViewDelegate
- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem {
  NSUInteger index = [tabView indexOfTabViewItem:tabViewItem];
  switch ((MPDatabaseSettingsTab)index) {
    case MPDatabaseSettingsTabSecurity:
    case MPDatabaseSettingsTabAdvanced:
    case MPDatabaseSettingsTabGeneral:
      return YES;
      
    default:
      return NO;
  }
}

#pragma mark Private Helper
- (void)_setupDatabaseTab:(KPKMetaData *)metaData {
  self.databaseNameTextField.stringValue = metaData.databaseName;
  self.databaseDescriptionTextView.string = metaData.databaseDescription;
  [self.databaseCompressionPopupButton selectItemAtIndex:metaData.compressionAlgorithm];
  NSColor *databaseColor = metaData.color ? metaData.color : [NSColor clearColor];
  self.databaseColorColorWell.color = databaseColor;
}

- (void)_setupSecurityTab:(KPKMetaData *)metaData {
  /* Tab 0 AES Tab 1 Argon2 */
  KPKKeyDerivation *keyDerivation = [KPKKeyDerivation keyDerivationWithParameters:metaData.keyDerivationParameters];
  
  NSUInteger kdfIndex = [self.keyDerivationPopupButton.menu indexOfItemWithRepresentedObject:keyDerivation.uuid];
  [self.keyDerivationPopupButton selectItemAtIndex:kdfIndex];
  
  if([keyDerivation isKindOfClass:[KPKAESKeyDerivation class]]) {
    [self.keyDerivationSettingsTabView selectTabViewItemAtIndex:0];
    KPKAESKeyDerivation *aesKDF = (KPKAESKeyDerivation *)keyDerivation;
    self.AESEncryptionRoundsTextField.integerValue = aesKDF.rounds;
    self.createKeyDerivationParametersButton.enabled = YES;
    
    /* fill defautls for Argon2 */
    KPKArgon2KeyDerivation *argon2Kdf = [[KPKArgon2KeyDerivation alloc] initWithParameters:[KPKArgon2KeyDerivation defaultParameters]];
    self.Argon2IterationsTextField.integerValue = argon2Kdf.iterations;
    self.Argon2MemoryTextField.integerValue = argon2Kdf.memory;
    self.Argon2ThreadsTextField.integerValue = argon2Kdf.threads;
  }
  else if([keyDerivation isKindOfClass:[KPKArgon2KeyDerivation class]]) {
    [self.keyDerivationSettingsTabView selectTabViewItemAtIndex:1];
    KPKArgon2KeyDerivation *argon2KDF = (KPKArgon2KeyDerivation *)keyDerivation;
    self.Argon2MemoryTextField.integerValue = argon2KDF.memory;
    self.Argon2ThreadsTextField.integerValue = argon2KDF.threads;
    self.Argon2IterationsTextField.integerValue = argon2KDF.iterations;
    
    /* fill defaults for AES */
    KPKAESKeyDerivation *aesKdf = [[KPKAESKeyDerivation alloc] initWithParameters:[KPKAESKeyDerivation defaultParameters]];
    self.AESEncryptionRoundsTextField.integerValue = aesKdf.rounds;
  }
  else {
    
  }
  
  NSUInteger cipherIndex = [self.encryptionPopupButton.menu indexOfItemWithRepresentedObject:metaData.cipherUUID];
  [self.encryptionPopupButton selectItemAtIndex:cipherIndex];
}

- (void)_setupAdvancedTab:(KPKTree *)tree {
  HNHUISetStateFromBool(self.enableTrashCheckButton, tree.metaData.useTrash);
  self.selectTrashGoupPopUpButton.enabled = tree.metaData.useTrash;
  [self.enableTrashCheckButton bind:NSValueBinding toObject:self.selectTrashGoupPopUpButton withKeyPath:NSEnabledBinding options:nil];
  [self _updateTrashFolders:tree];
  
  self.defaultUsernameTextField.stringValue = tree.metaData.defaultUserName;
  self.defaultUsernameTextField.editable = YES;
  [self _updateTemplateGroup:tree];
  
  HNHUISetStateFromBool(self.enforceKeyChangeCheckButton, tree.metaData.enforceMasterKeyChange);
  HNHUISetStateFromBool(self.recommendKeyChangeCheckButton, tree.metaData.recommendMasterKeyChange);
  [self.enforceKeyChangeIntervalTextField setEnabled:tree.metaData.enforceMasterKeyChange];
  [self.recommendKeyChangeIntervalTextField setEnabled:tree.metaData.recommendMasterKeyChange];

  self.enforceKeyChangeIntervalTextField.stringValue = @"";
  if(tree.metaData.enforceMasterKeyChange) {
    self.enforceKeyChangeIntervalTextField.integerValue = tree.metaData.masterKeyChangeEnforcementInterval;
  }
  self.recommendKeyChangeIntervalTextField.stringValue = @"";
  if(tree.metaData.recommendMasterKeyChange) {
    self.recommendKeyChangeIntervalTextField.integerValue = tree.metaData.masterKeyChangeRecommendationInterval;
  }
  [self.enforceKeyChangeCheckButton bind:NSValueBinding toObject:self.enforceKeyChangeIntervalTextField withKeyPath:NSEnabledBinding options:nil];
  [self.recommendKeyChangeCheckButton bind:NSValueBinding toObject:self.recommendKeyChangeIntervalTextField withKeyPath:NSEnabledBinding options:nil];
}

- (void)_updateFirstResponder {
  NSTabViewItem *selected = self.sectionTabView.selectedTabViewItem;
  MPDatabaseSettingsTab tab = [self.sectionTabView.tabViewItems indexOfObject:selected];
  
  switch(tab) {
    case MPDatabaseSettingsTabAdvanced:
      [self.window makeFirstResponder:self.defaultUsernameTextField];
      break;
      
    case MPDatabaseSettingsTabSecurity:
      //[self.window makeFirstResponder:self.protectTitleCheckButton];
      break;
      
    case MPDatabaseSettingsTabGeneral:
      [self.window makeFirstResponder:self.databaseNameTextField];
      break;
  }
}

- (void)_updateTrashFolders:(KPKTree *)tree {
  NSMenu *menu = [self _buildTrashTreeMenu:tree];
  self.selectTrashGoupPopUpButton.menu = menu;
}

- (void)_updateTemplateGroup:(KPKTree *)tree {
  NSMenu *menu = [self _buildTemplateTreeMenu:tree];
  self.templateGroupPopUpButton.menu = menu;
}

- (NSMenu *)_buildTrashTreeMenu:(KPKTree *)tree {
  NSMenu *menu = [self _buildTreeMenu:tree preselect:tree.metaData.trashUuid];
  
  NSMenuItem *selectItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"AUTOCREATE_TRASH_FOLDER", @"Menu item for automatic trash creation")
                                                      action:NULL
                                               keyEquivalent:@""];
  selectItem.enabled = YES;
  [menu insertItem:selectItem atIndex:0];
  
  return menu;
}

- (NSMenu *)_buildTemplateTreeMenu:(KPKTree *)tree {
  NSMenu *menu = [self _buildTreeMenu:tree preselect:tree.metaData.entryTemplatesGroup];
  
  NSMenuItem *selectItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"NO_TEMPLATE_GROUP", @"Menu item to reset the template groups")
                                                      action:NULL
                                               keyEquivalent:@""];
  selectItem.enabled = YES;
  [menu insertItem:selectItem atIndex:0];
  
  return menu;
}


- (NSMenu *)_buildTreeMenu:(KPKTree *)tree preselect:(NSUUID *)uuid {
  NSMenu *menu = [[NSMenu alloc] init];
  menu.autoenablesItems = NO;
  for(KPKGroup *group in tree.root.groups) {
    [self _insertMenuItemsForGroup:group atLevel:0 inMenu:menu preselect:uuid];
  }
  return menu;
}

- (void)_insertMenuItemsForGroup:(KPKGroup *)group atLevel:(NSUInteger)level inMenu:(NSMenu *)menu preselect:(NSUUID *)uuid{
  NSMenuItem *groupItem = [[NSMenuItem alloc] init];
  groupItem.image = group.iconImage;
  groupItem.title = group.title;
  groupItem.representedObject = group;
  groupItem.enabled = YES;
  if(uuid && [group.uuid isEqual:uuid]) {
    groupItem.state = NSOnState;
  }
  groupItem.indentationLevel = level;
  [menu addItem:groupItem];
  for(KPKGroup *childGroup in group.groups) {
    [self _insertMenuItemsForGroup:childGroup atLevel:level + 1 inMenu:menu preselect:uuid];
  }
}

@end
