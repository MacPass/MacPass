//
//  MPAdvancedDatabaseSettingsViewController.m
//  MacPass
//
//  Created by Michael Starke on 18.11.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//

#import "MPAdvancedDatabaseSettingsViewController.h"
#import "MPDocument.h"
#import "MPDayCountFormatter.h"
#import "KPKNode+IconImage.h"

#import <KeePassKit/KeePassKit.h>
#import <HNHUi/HNHUi.h>

@interface MPAdvancedDatabaseSettingsViewController ()

@property (strong) IBOutlet NSButton *enableHistoryCheckButton;
@property (strong) IBOutlet NSTextField *historyMaximumItemsTextField;
@property (strong) IBOutlet NSStepper *historyMaximumItemsStepper;

@property (strong) IBOutlet NSTextField *historyMaximumSizeTextField;
@property (strong) IBOutlet NSStepper *historyMaximumSizeStepper;

@property (strong) IBOutlet NSButton *enableTrashCheckButton;
@property (strong) IBOutlet NSButton *emptyTrashOnQuitCheckButton;
@property (strong) IBOutlet NSPopUpButton *selectTrashGoupPopUpButton;
@property (strong) IBOutlet NSTextField *defaultUsernameTextField;
@property (strong) IBOutlet NSPopUpButton *templateGroupPopUpButton;

@property (strong) IBOutlet NSButton *recommendKeyChangeCheckButton;
@property (strong) IBOutlet NSButton *enforceKeyChangeCheckButton;
@property (strong) IBOutlet NSButton *enforceKeyChangeOnceCheckButton;
@property (strong) IBOutlet NSTextField *recommendKeyChangeIntervalTextField;
@property (strong) IBOutlet NSStepper *recommendKeyChangeIntervalStepper;
@property (strong) IBOutlet NSTextField *enforceKeyChangeIntervalTextField;
@property (strong) IBOutlet NSStepper *enforceKeyChangeIntervalStepper;

@property (assign) BOOL enableHistory;
@property (assign) NSInteger maxiumHistoryItems;
@property (assign) NSInteger maxiumHistorySize;

@property (assign) BOOL enforceKeyChange;
@property (assign) BOOL recommendKeyChange;
@property (assign) NSInteger enforceKeyChangeInterval;
@property (assign) NSInteger recommendKeyChangeInterval;

@end

@implementation MPAdvancedDatabaseSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)_setupAdvancedTab {
  /* history */
  MPDocument *document = (MPDocument*)self.view.window.windowController.document;
  KPKTree *tree = document.tree;
  
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
