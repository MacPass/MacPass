//
//  MPDocumentSettingsWindowController.m
//  MacPass
//
//  Created by Michael Starke on 26.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "MPDatabaseSettingsWindowController.h"
#import "MPDocument.h"
#import "MPDocumentWindowController.h"
#import "MPDatabaseVersion.h"
#import "MPIconHelper.h"
#import "MPSettingsHelper.h"
#import "MPNumericalInputFormatter.h"
#import "MPDayCountFormatter.h"

#import "KeePassKit/KeePassKit.h"

#import "HNHUi/HNHUi.h"

#import "KPKNode+IconImage.h"

@interface MPDatabaseSettingsWindowController () {
  NSString *_missingFeature;
}

@property (assign) NSInteger argon2Memory;

@property (assign) BOOL enableHistory;
@property (assign) NSInteger maxiumHistoryItems;
@property (assign) NSInteger maxiumHistorySize;

@property (assign) BOOL enforceKeyChange;
@property (assign) BOOL recommendKeyChange;
@property (assign) NSInteger enforceKeyChangeInterval;
@property (assign) NSInteger recommendKeyChangeInterval;

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
  self.aesEncryptionRoundsTextField.formatter = [[MPNumericalInputFormatter alloc] init];
  
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
  self.cipherPopupButton.menu = cipherMenu;
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
  /* TODO move settingsChanged updates to KeePassKit as it's the models responsibility */
  metaData.settingsChanged = NSDate.date;
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
  
  BOOL requiresHistoryMaintainance = NO;
  requiresHistoryMaintainance = (metaData.historyMaxSize > self.historyMaximumSizeTextField.integerValue ||
                                 metaData.historyMaxItems > self.historyMaximumItemsTextField.integerValue);
  
  metaData.historyMaxItems = self.enableHistory ? self.maxiumHistoryItems : -1;
  metaData.historyMaxSize = self.maxiumHistorySize;
  
  /* only maintain history if actually needed */
  if(requiresHistoryMaintainance) {
    KPKTree *tree = ((MPDocument *)self.document).tree;
    [tree maintainHistory];
  }
  
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
  metaData.enforceMasterKeyChangeOnce = HNHUIBoolForState(self.enforceKeyChangeOnceCheckButton.state);
  
  metaData.defaultUserName = self.defaultUsernameTextField.stringValue;
  
  /* Security */
  metaData.cipherUUID = self.cipherPopupButton.selectedItem.representedObject;
  
  KPKAESKeyDerivation *aesKdf = [[KPKAESKeyDerivation alloc] initWithParameters:[KPKAESKeyDerivation defaultParameters]];
  KPKArgon2KeyDerivation *argon2Kdf = [[KPKArgon2KeyDerivation alloc] initWithParameters:[KPKArgon2KeyDerivation defaultParameters]];
  
  NSUUID *selectedKdfUUID = self.keyDerivationSettingsTabView.selectedTabViewItem.identifier;
  
  if([selectedKdfUUID isEqual:aesKdf.uuid]) {
    aesKdf.rounds = self.aesEncryptionRoundsTextField.integerValue;
    metaData.keyDerivationParameters = aesKdf.parameters;
  }
  else if([selectedKdfUUID isEqual:argon2Kdf.uuid]) {
    argon2Kdf.iterations = self.argon2IterationsTextField.integerValue;
    argon2Kdf.memory = self.argon2Memory;
    argon2Kdf.threads = self.argon2ThreadsTextField.intValue;
    metaData.keyDerivationParameters = argon2Kdf.parameters;
  }
  
  /* Changes to metadata aren't backed by undomanager, thus we need to manually set the document dirty */
  [self.document updateChangeCount:NSChangeDone];
  [self close:nil];
}

- (IBAction)close:(id)sender {
  [self dismissSheet:0];
}

- (IBAction)benchmarkRounds:(id)sender {
  self.createKeyDerivationParametersButton.enabled = NO;
  [KPKAESKeyDerivation parametersForDelay:1 completionHandler:^(NSDictionary * _Nonnull options) {
    self.aesEncryptionRoundsTextField.integerValue = [options[KPKAESRoundsOption] unsignedInteger64Value];
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
  KPKTree *tree = ((MPDocument *)self.document).tree;
  [self _setupDatabaseTab:tree];
  [self _setupSecurityTab:tree.metaData];
  [self _setupAdvancedTab:tree];
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
- (void)_setupDatabaseTab:(KPKTree *)tree {
  self.databaseNameTextField.stringValue = tree.metaData.databaseName;
  self.databaseDescriptionTextView.string = tree.metaData.databaseDescription;
  [self.databaseCompressionPopupButton selectItemAtIndex:tree.metaData.compressionAlgorithm];
  self.databaseColorColorWell.color = tree.metaData.color ? tree.metaData.color : NSColor.clearColor;
  
  
  NSData *fileData = [NSData dataWithContentsOfURL:((MPDocument *)self.document).fileURL];
  if(!fileData) {
    self.fileVersionTextField.stringValue = NSLocalizedString(@"UNKNOWN_FORMAT_FILE_NOT_SAVED_YET", "Database format is unknown since the file is not saved yet");
  }
  else {
    KPKFileVersion version = [[KPKFormat sharedFormat] fileVersionForData:fileData];
    NSDictionary *nameMappings = @{
                                   @(KPKDatabaseFormatKdb): @"Kdb",
                                   @(KPKDatabaseFormatKdbx): @"Kdbx",
                                   @(KPKDatabaseFormatUnknown): NSLocalizedString(@"UNKNOWN_FORMAT", "Unknown database format.")
                                   };
    
    NSUInteger mayor = (version.version >> 16);
    NSUInteger minor = (version.version & 0xFFFF);
    
    self.fileVersionTextField.stringValue = [NSString stringWithFormat:@"%@ (Version %ld.%ld)", nameMappings[@(version.format)], mayor, minor];
  }
}

- (void)_setupSecurityTab:(KPKMetaData *)metaData {
  /*
   If kdf or cipher is not found, exceptions are thrown.
   This should not happen since we should not be able to load a file with unknown cipher/kdf
   */
  KPKKeyDerivation *keyDerivation = [KPKKeyDerivation keyDerivationWithParameters:metaData.keyDerivationParameters];
  NSUInteger kdfIndex = [self.keyDerivationPopupButton.menu indexOfItemWithRepresentedObject:keyDerivation.uuid];
  [self.keyDerivationPopupButton selectItemAtIndex:kdfIndex];
  [self.keyDerivationSettingsTabView selectTabViewItemWithIdentifier:keyDerivation.uuid];
  
  if([keyDerivation isKindOfClass:[KPKAESKeyDerivation class]]) {
    KPKAESKeyDerivation *aesKdf = (KPKAESKeyDerivation *)keyDerivation;
    self.aesEncryptionRoundsTextField.integerValue = aesKdf.rounds;
    self.createKeyDerivationParametersButton.enabled = YES;
    
    /* fill defaults for Argon2 */
    KPKArgon2KeyDerivation *argon2Kdf = [[KPKArgon2KeyDerivation alloc] initWithParameters:[KPKArgon2KeyDerivation defaultParameters]];
    self.argon2IterationsTextField.integerValue = argon2Kdf.iterations;
    self.argon2Memory = argon2Kdf.memory;
    self.argon2ThreadsTextField.integerValue = argon2Kdf.threads;
  }
  else if([keyDerivation isKindOfClass:[KPKArgon2KeyDerivation class]]) {
    KPKArgon2KeyDerivation *argon2Kdf = (KPKArgon2KeyDerivation *)keyDerivation;
    self.argon2Memory = argon2Kdf.memory;
    self.argon2ThreadsTextField.integerValue = argon2Kdf.threads;
    self.argon2IterationsTextField.integerValue = argon2Kdf.iterations;
    
    /* fill defaults for AES */
    KPKAESKeyDerivation *aesKdf = [[KPKAESKeyDerivation alloc] initWithParameters:[KPKAESKeyDerivation defaultParameters]];
    self.aesEncryptionRoundsTextField.integerValue = aesKdf.rounds;
  }
  else {
    NSAssert(NO, @"Unkown key derivation");
  }
  
  self.argon2MemoryStepper.minValue = 8*1024; // 8KB minimum
  self.argon2MemoryStepper.maxValue = NSIntegerMax;
  self.argon2MemoryStepper.increment = 1024*1024; // 1 megabytes steps
  [self.argon2MemoryTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(argon2Memory)) options:nil];
  [self.argon2MemoryStepper bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(argon2Memory)) options:nil];
  
  
  NSUInteger cipherIndex = [self.cipherPopupButton.menu indexOfItemWithRepresentedObject:metaData.cipherUUID];
  [self.cipherPopupButton selectItemAtIndex:cipherIndex];
}

- (void)_setupAdvancedTab:(KPKTree *)tree {
  /* history */
  self.enableHistory = tree.metaData.isHistoryEnabled;
  [self.enableHistoryCheckButton bind:NSValueBinding
                             toObject:self
                          withKeyPath:NSStringFromSelector(@selector(enableHistory))
                              options:nil];
  
  /* history size */
  self.maxiumHistorySize = tree.metaData.historyMaxSize;
  self.historyMaximumSizeStepper.minValue = 0;
  self.historyMaximumSizeStepper.maxValue = NSIntegerMax;
  self.historyMaximumSizeStepper.increment = 1024*1024; // 1MB
  [self.historyMaximumSizeStepper bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(enableHistory)) options:nil];
  [self.historyMaximumSizeStepper bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(maxiumHistorySize)) options:nil];
  [self.historyMaximumSizeTextField bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(enableHistory)) options:nil];
  [self.historyMaximumSizeTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(maxiumHistorySize)) options:nil];
  
  /* history count */
  self.maxiumHistoryItems = MAX(0,tree.metaData.historyMaxItems); // prevent -1 form showing up directly
  self.historyMaximumItemsStepper.minValue = 0;
  self.historyMaximumItemsStepper.maxValue = NSIntegerMax;
  self.historyMaximumItemsStepper.increment = 1;
  [self.historyMaximumItemsStepper bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(enableHistory)) options:nil];
  [self.historyMaximumItemsStepper bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(maxiumHistoryItems)) options:nil];
  [self.historyMaximumItemsTextField bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(enableHistory)) options:nil];
  [self.historyMaximumItemsTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(maxiumHistoryItems)) options:nil];
  
  /* trash */
  HNHUISetStateFromBool(self.enableTrashCheckButton, tree.metaData.useTrash);
  self.selectTrashGoupPopUpButton.enabled = tree.metaData.useTrash;
  [self.enableTrashCheckButton bind:NSValueBinding toObject:self.selectTrashGoupPopUpButton withKeyPath:NSEnabledBinding options:nil];
  [self _updateTrashFolders:tree];
  
  /* default username */
  self.defaultUsernameTextField.stringValue = tree.metaData.defaultUserName;
  self.defaultUsernameTextField.editable = YES;
  [self _updateTemplateGroup:tree];
  
  /* key changes */
  self.enforceKeyChange = tree.metaData.enforceMasterKeyChange;
  self.recommendKeyChange = tree.metaData.recommendMasterKeyChange;
  HNHUISetStateFromBool(self.enforceKeyChangeOnceCheckButton, tree.metaData.enforceMasterKeyChangeOnce);
  
  [self.enforceKeyChangeCheckButton bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(enforceKeyChange)) options:nil];
  [self.recommendKeyChangeCheckButton bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(recommendKeyChange)) options:nil];
  
  /* intervals use -1 to encode disabled, do not show this in text fields! */
  self.enforceKeyChangeInterval = MAX(0,tree.metaData.masterKeyChangeEnforcementInterval);
  self.enforceKeyChangeIntervalStepper.minValue = 0;
  self.enforceKeyChangeIntervalStepper.maxValue = NSIntegerMax;
  self.enforceKeyChangeIntervalStepper.increment = 1; // 1 day steps
  [self.enforceKeyChangeIntervalStepper bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(enforceKeyChange)) options:nil];
  [self.enforceKeyChangeIntervalStepper bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(enforceKeyChangeInterval)) options:nil];
  [self.enforceKeyChangeIntervalTextField bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(enforceKeyChange)) options:nil];
  [self.enforceKeyChangeIntervalTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(enforceKeyChangeInterval)) options:nil];
  
  NSString *valueFormat = NSLocalizedString(@"EVERY_%ld_DAYS", @"Recommend/Enforce key change intervall format");
  
  ((MPDayCountFormatter *)self.enforceKeyChangeIntervalTextField.formatter).valueFormat = valueFormat;
  
  self.recommendKeyChangeInterval = MAX(0,tree.metaData.masterKeyChangeRecommendationInterval);
  self.recommendKeyChangeIntervalStepper.minValue = 0;
  self.recommendKeyChangeIntervalStepper.maxValue = NSIntegerMax;
  self.recommendKeyChangeIntervalStepper.increment = 1; // 1 day steps
  [self.recommendKeyChangeIntervalStepper bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(recommendKeyChange)) options:nil];
  [self.recommendKeyChangeIntervalStepper bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(recommendKeyChangeInterval)) options:nil];
  [self.recommendKeyChangeIntervalTextField bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(recommendKeyChange)) options:nil];
  [self.recommendKeyChangeIntervalTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(recommendKeyChangeInterval)) options:nil];
  ((MPDayCountFormatter *)self.recommendKeyChangeIntervalTextField.formatter).valueFormat = valueFormat;
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
  NSMenu *menu = [self _buildTreeMenu:tree preselect:tree.metaData.entryTemplatesGroupUuid];
  
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
