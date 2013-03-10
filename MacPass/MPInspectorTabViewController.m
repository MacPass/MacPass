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
#import "KdbLib.h"

@interface MPInspectorTabViewController ()

@property (assign) IBOutlet MPPopupImageView *itemImageView;
@property (assign) IBOutlet NSTextField *itemNameTextfield;
@property (assign) IBOutlet NSTabView *tabView;
@property (assign) IBOutlet NSSegmentedControl *tabControl;
@property (assign) NSUInteger selectedTabIndex;
@property (assign, nonatomic) KdbEntry *selectedEntry;

- (void)_didChangeSelectedEntry:(NSNotification *)notification;
- (void)_updateContent;
- (void)_clearContent;
- (void)_setInputEnabled:(BOOL)enabled;

@end

@implementation MPInspectorTabViewController

- (id)init {
  return [[MPInspectorTabViewController alloc] initWithNibName:@"InspectorTabView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      _selectedEntry = nil;
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

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didChangeSelectedEntry:)
                                               name:MPDidChangeSelectedEntryNotification
                                             object:nil];
  
  [self _clearContent];
}

- (void)_updateContent {
  if(self.selectedEntry) {
    [self.itemNameTextfield setStringValue:self.selectedEntry.title];
    [self.itemImageView setImage:[MPIconHelper icon:(MPIconType)self.selectedEntry.image ]];
    [self _setInputEnabled:YES];
  }
  else {
    [self _clearContent];
  }
}

- (void)_clearContent {
  [self _setInputEnabled:NO];
  [self.itemNameTextfield setStringValue:NSLocalizedString(@"INSPECTOR_NO_SELECTION", @"No item selected in inspector")];
  [self.itemImageView setImage:[NSImage imageNamed:NSImageNameActionTemplate]];
}

- (void)_setInputEnabled:(BOOL)enabled {
  [self.itemImageView setEnabled:enabled];
  [self.itemNameTextfield setTextColor: enabled ? [NSColor controlTextColor] : [NSColor disabledControlTextColor] ];
  [self.itemNameTextfield setEnabled:enabled];
}

#pragma mark Notificiations

- (void)_didChangeSelectedEntry:(NSNotification *)notification {
  MPEntryViewController *entryViewController = [notification object];
  if(entryViewController) {
    self.selectedEntry = entryViewController.selectedEntry;
  }
}

#pragma mark Properties
- (void)setSelectedEntry:(KdbEntry *)selectedEntry {
  if(_selectedEntry != selectedEntry) {
    _selectedEntry = selectedEntry;
    [self _updateContent];
  }
}

@end
