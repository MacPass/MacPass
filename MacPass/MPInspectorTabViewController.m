//
//  MPInspectorTabViewController.m
//  MacPass
//
//  Created by Michael Starke on 05.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPInspectorTabViewController.h"
#import "MPEntryViewController.h"
#import "MPOutlineViewDelegate.h"
#import "MPDatabaseController.h"
#import "MPShadowBox.h"
#import "MPIconHelper.h"
#import "MPPopupImageView.h"
#import "MPIconSelectViewController.h"
#import "KdbLib.h"

@interface MPInspectorTabViewController ()

@property (assign) NSUInteger selectedTabIndex;
@property (assign, nonatomic) KdbEntry *selectedEntry;
@property (assign, nonatomic) KdbGroup *selectedGroup;
@property (assign) BOOL showsEntry;

- (void)_didChangeSelectedEntry:(NSNotification *)notification;
- (void)_didChangeSelectedGroup:(NSNotification *)notification;
- (void)_updateContent;
- (void)_showGroup;
- (void)_showEntry;
- (void)_clearContent;
- (void)_setInputEnabled:(BOOL)enabled;
- (void)_showImagePopup:(id)sender;

@end

@implementation MPInspectorTabViewController

- (id)init {
  return [[MPInspectorTabViewController alloc] initWithNibName:@"InspectorTabView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _selectedEntry = nil;
    _selectedGroup = nil;
    _showsEntry = NO;
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (void)didLoadView {
  
  for( NSTabViewItem *item in  [self.tabView tabViewItems]){
    ((MPShadowBox *)[item view]).shadowDisplay = MPShadowTop;
  }
  [[self.itemImageView cell] setBackgroundStyle:NSBackgroundStyleRaised];
  [self.tabControl bind:NSSelectedIndexBinding toObject:self withKeyPath:@"selectedTabIndex" options:nil];
  [self.tabView bind:NSSelectedIndexBinding toObject:self withKeyPath:@"selectedTabIndex" options:nil];
  [self.itemImageView setTarget:self];
  
  /* Register for Entry selection */
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didChangeSelectedEntry:)
                                               name:MPDidChangeSelectedEntryNotification
                                             object:nil];
  
  /* Register for Group selection */
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didChangeSelectedGroup:)
                                               name:MPOutlineViewDidChangeGroupSelection
                                             object:nil];
  
  [self _clearContent];
}

- (void)_updateContent {
  if(self.showsEntry && self.selectedEntry) {
    [self _showEntry];
  }
  else if(!self.showsEntry && self.selectedGroup) {
    [self _showGroup];
  }
  else {
    [self _clearContent];
  }
}

- (void)_showEntry {
  [self.itemNameTextfield setStringValue:self.selectedEntry.title];
  [self.itemImageView setImage:[MPIconHelper icon:(MPIconType)self.selectedEntry.image ]];
  [self.passwordTextField setStringValue:self.selectedEntry.password];
  [self.usernameTextField setStringValue:self.selectedEntry.username];
  [self.titleOrNameLabel setStringValue:NSLocalizedString(@"TITLE",@"")];
  [self.titleTextField setStringValue:self.selectedEntry.title];
  [self.URLTextField setStringValue:self.selectedEntry.url];
  
  [self _setInputEnabled:YES];
}

- (void)_showGroup {
  [self.itemNameTextfield setStringValue:self.selectedGroup.name];
  [self.itemImageView setImage:[MPIconHelper icon:(MPIconType)self.selectedGroup.image ]];
  [self.titleOrNameLabel setStringValue:NSLocalizedString(@"NAME",@"")];
  [self.titleTextField setStringValue:self.selectedGroup.name];
  [self _setInputEnabled:YES];
}

- (void)_clearContent {
  
  [self _setInputEnabled:NO];
  [self.itemNameTextfield setStringValue:NSLocalizedString(@"INSPECTOR_NO_SELECTION", @"No item selected in inspector")];
  [self.itemImageView setImage:[NSImage imageNamed:NSImageNameActionTemplate]];
  
  [self.itemNameTextfield setStringValue:@""];
  [self.passwordTextField setStringValue:@""];
  [self.usernameTextField setStringValue:@""];
  [self.titleTextField setStringValue:@""];
  [self.URLTextField setStringValue:@""];
  
}

- (void)_setInputEnabled:(BOOL)enabled {
  
  [self.itemImageView setAction: enabled ? @selector(_showImagePopup:) : NULL ];
  [self.itemImageView setEnabled:enabled];
  [self.itemNameTextfield setTextColor: enabled ? [NSColor controlTextColor] : [NSColor disabledControlTextColor] ];
  [self.itemNameTextfield setEnabled:enabled];
  [self.titleTextField setEnabled:enabled];
  
  enabled &= self.showsEntry;
  [self.passwordTextField setEnabled:enabled];
  [self.usernameTextField setEnabled:enabled];
  [self.URLTextField setEnabled:enabled];
  
  [self.togglePasswordDisplayButton setEnabled:enabled];
  [self.openURLButton setEnabled:enabled];
  
}

#pragma mark Actions

- (void)_showImagePopup:(id)sender {
  NSPopover *popover = [[NSPopover alloc] init];
  popover.behavior = NSPopoverBehaviorTransient;
  popover.contentViewController = [[[MPIconSelectViewController alloc] init] autorelease];
  [popover showRelativeToRect:NSZeroRect ofView:self.itemImageView preferredEdge:NSMinYEdge];
  [popover release];
}

#pragma mark Notificiations

- (void)_didChangeSelectedEntry:(NSNotification *)notification {
  MPEntryViewController *entryViewController = [notification object];
  if(entryViewController) {
    self.selectedEntry = entryViewController.selectedEntry;
  }
}

- (void)_didChangeSelectedGroup:(NSNotification *)notification {
  MPOutlineViewDelegate *outlineViewDelegae = [notification object];
  if(outlineViewDelegae) {
    self.selectedGroup = outlineViewDelegae.selectedGroup;
  }
}

#pragma mark Properties
- (void)setSelectedEntry:(KdbEntry *)selectedEntry {
  if(_selectedEntry != selectedEntry) {
    _selectedEntry = selectedEntry;
    self.showsEntry = YES;
    [self _updateContent];
  }
}

- (void)setSelectedGroup:(KdbGroup *)selectedGroup {
  if(_selectedGroup != selectedGroup) {
    _selectedGroup = selectedGroup;
    self.showsEntry = NO;
    [self _updateContent];
  }
}


- (IBAction)togglePasswordDisplay:(id)sender {
}
@end
