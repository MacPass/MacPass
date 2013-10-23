//
//  MPInspectorTabViewController.m
//  MacPass
//
//  Created by Michael Starke on 05.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPInspectorViewController.h"
#import "MPIconHelper.h"
#import "MPEntryInspectorViewController.h"
#import "MPGroupInspectorViewController.h"
#import "MPDocument.h"
#import "MPNotifications.h"
#import "MPIconSelectViewController.h"

#import "NSDate+Humanized.h"

#import "KPKTree.h"
#import "KPKMetaData.h"

#import "HNHGradientView.h"
#import "MPPopupImageView.h"

typedef NS_ENUM(NSUInteger, MPContentTab) {
  MPEntryTab,
  MPGroupTab,
  MPEmptyTab
};

@interface MPInspectorViewController () {
  MPEntryInspectorViewController *_entryViewController;
  MPGroupInspectorViewController *_groupViewController;
  NSPopover *_popover;
}

@property (nonatomic, strong) NSDate *modificationDate;
@property (nonatomic, strong) NSDate *creationDate;

@property (nonatomic, assign) BOOL showEditButton;

@property (nonatomic, assign) NSUInteger activeTab;
@property (weak) IBOutlet NSTabView *tabView;

@end

@implementation MPInspectorViewController

- (id)init {
  return [[MPInspectorViewController alloc] initWithNibName:@"InspectorView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _activeTab = MPEmptyTab;
    _entryViewController = [[MPEntryInspectorViewController alloc] init];
    _groupViewController = [[MPGroupInspectorViewController alloc] init];
    _showEditButton = NO;
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Properties
- (void)setActiveTab:(NSUInteger)activeTab {
  if(_activeTab != activeTab) {
    _activeTab = activeTab;
    self.showEditButton = [[[self windowController] document] tree].metaData.isHistoryEnabled;
  }
}

- (void)setShowEditButton:(BOOL)showEditButton {
  showEditButton &= (self.activeTab == MPEntryTab);
  if(_showEditButton != showEditButton) {
    _showEditButton = showEditButton;
  }
}

- (void)didLoadView {
  [_bottomBar setBorderType:HNHBorderTop];
  [[self.noSelectionInfo cell] setBackgroundStyle:NSBackgroundStyleRaised];
  [[self.itemImageView cell] setBackgroundStyle:NSBackgroundStyleRaised];
  [self.tabView bind:NSSelectedIndexBinding toObject:self withKeyPath:@"activeTab" options:nil];
  
  NSView *entryView = [_entryViewController view];
  NSView *groupView = [_groupViewController view];
  
  NSView *entryTabView = [[self.tabView tabViewItemAtIndex:MPEntryTab] view];
  [entryTabView addSubview:entryView];
  NSDictionary *views = NSDictionaryOfVariableBindings(entryView, groupView);
  [entryTabView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[entryView]|" options:0 metrics:nil views:views]];
  [entryTabView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[entryView]|" options:0 metrics:nil views:views]];
  
  NSView *groupTabView = [[self.tabView tabViewItemAtIndex:MPGroupTab] view];
  [groupTabView addSubview:groupView];
  [groupTabView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[groupView]|" options:0 metrics:nil views:views]];
  [groupTabView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[groupView]|" options:0 metrics:nil views:views]];
  
  [_groupViewController updateResponderChain];
  [_entryViewController updateResponderChain];
  
  [[self view] layoutSubtreeIfNeeded];
  
  [self _updateItemBindings:nil];
}

- (void)setupNotifications:(NSWindowController *)windowController {
  MPDocument *document = [windowController document];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didChangeCurrentItem:)
                                               name:MPCurrentItemChangedNotification
                                             object:document];
  [_entryViewController setupBindings:document];
  [_groupViewController setupBindings:document];
  
}

- (void)setModificationDate:(NSDate *)modificationDate {
  _modificationDate = modificationDate;
  [self _updateDateStrings];
}

- (void)setCreationDate:(NSDate *)creationDate {
  _creationDate = creationDate;
  [self _updateDateStrings];
}

- (void)_updateDateStrings {
  
  if(!self.creationDate || !self.modificationDate ) {
    [self.modifiedTextField setStringValue:@""];
    [self.createdTextField setStringValue:@""];
    return; // No dates, just clear
  }
  
  NSString *creationString = [self.creationDate humanized];
  NSString *modificationString = [self.modificationDate humanized];
  
  NSString *modifedAtTemplate = NSLocalizedString(@"MODIFED_AT_%@", @"Modifed at template string. %@ is replaced by locaized date and time");
  NSString *createdAtTemplate = NSLocalizedString(@"CREATED_AT_%@", @"Created at template string. %@ is replaced by locaized date and time");
  
  [self.modifiedTextField setStringValue:[NSString stringWithFormat:modifedAtTemplate, modificationString]];
  [self.createdTextField setStringValue:[NSString stringWithFormat:createdAtTemplate, creationString]];
  
}

#pragma mark -
#pragma mark Popup
- (IBAction)showImagePopup:(id)sender {
  
  NSAssert(_popover == nil, @"Popover hast to be niled out");
  _popover = [[NSPopover alloc] init];
  _popover.delegate = self;
  _popover.behavior = NSPopoverBehaviorTransient;
  _popover.contentViewController = [[MPIconSelectViewController alloc] init];
  [_popover showRelativeToRect:NSZeroRect ofView:self.itemImageView preferredEdge:NSMinYEdge];
}

- (void)popoverDidClose:(NSNotification *)notification {
  _popover = nil;
}

#pragma mark -
#pragma mark Bindings
- (void)prepareView {
  MPDocument *document = [[self windowController] document];
  [self bind:@"showEditButton" toObject:document.tree.metaData withKeyPath:@"isHistoryEnabled" options:nil];
  NSDictionary *bindingOptions = @{ NSValueTransformerNameBindingOption : NSNegateBooleanTransformerName };
  [self.editButton bind:NSHiddenBinding toObject:self withKeyPath:@"showEditButton" options:bindingOptions];
}

- (void)_updateItemBindings:(id)item {
  if(!item) {
    [self.itemNameTextField unbind:NSValueBinding];
    [self.itemNameTextField setHidden:YES];
    [self.itemImageView unbind:NSValueBinding];
    [self.itemImageView setHidden:YES];

    return;
  }

  [self.itemImageView bind:NSValueBinding toObject:item withKeyPath:@"iconImage" options:nil];
  
  if([item respondsToSelector:@selector(title)]) {
    [self.itemNameTextField bind:NSValueBinding toObject:item withKeyPath:@"title" options:nil];
  }
  else if( [item respondsToSelector:@selector(name)]) {
    [self.itemNameTextField bind:NSValueBinding toObject:item withKeyPath:@"name" options:nil];
  }
  [self.itemImageView setHidden:NO];
  [self.itemNameTextField setHidden:NO];
}

#pragma mark -
#pragma mark Notificiations

- (void)_didChangeCurrentItem:(NSNotification *)notification {
  MPDocument *document = [notification object];
  if(!document.selectedItem) {
    /* show emty tab and hide edit button */
    self.activeTab = MPEmptyTab;
  }
  else {
    BOOL isGroup = document.selectedItem == document.selectedGroup;
    BOOL isEntry = document.selectedItem == document.selectedEntry;
    if(isGroup) {
      self.activeTab = MPGroupTab;
    }
    else if(isEntry) {
      self.activeTab = MPEntryTab;
    }
  }
  [self _updateItemBindings:document.selectedItem];
}
@end