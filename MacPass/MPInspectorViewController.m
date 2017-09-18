//
//  MPInspectorTabViewController.m
//  MacPass
//
//  Created by Michael Starke on 05.03.13.
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

#import "MPInspectorViewController.h"
#import "MPDatePickingViewController.h"
#import "MPDocument.h"
#import "MPEntryInspectorViewController.h"
#import "MPGroupInspectorViewController.h"
#import "MPIconHelper.h"
#import "MPIconSelectViewController.h"
#import "MPIconImageView.h"
#import "MPNotifications.h"
#import "MPPluginDataViewController.h"

#import "KeePassKit/KeePassKit.h"

#import "KPKNode+IconImage.h"

#import "HNHUi/HNHUi.h"

#import "NSDate+Humanized.h"

typedef NS_ENUM(NSUInteger, MPContentTab) {
  MPEntryTab,
  MPGroupTab,
  MPEmptyTab,
};

@interface MPInspectorViewController ()

@property (strong) MPEntryInspectorViewController *entryViewController;
@property (strong) MPGroupInspectorViewController *groupViewController;

@property (strong) NSPopover *popover;

@property (nonatomic, strong) NSDate *modificationDate;
@property (nonatomic, strong) NSDate *creationDate;
@property (copy) NSString *expiryDateText;

@property (nonatomic, assign) NSUInteger activeTab;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSSplitView *splitView;
@property (unsafe_unretained) IBOutlet NSTextView *notesTextView;

@property BOOL didPushHistory;

@end

@implementation MPInspectorViewController

- (NSString *)nibName {
  return @"InspectorView";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.activeTab = MPEmptyTab;
    self.entryViewController = [[MPEntryInspectorViewController alloc] init];
    self.groupViewController = [[MPGroupInspectorViewController alloc] init];
    self.didPushHistory = NO;
    /* subviewcontrollers will notify us about a change so we can handle the history pushing */
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSResponder *)reconmendedFirstResponder {
  return self.view;
}

- (void)awakeFromNib {
  self.bottomBar.borderType = (HNHBorderTop|HNHBorderHighlight);
  
  self.noSelectionInfo.cell.backgroundStyle = NSBackgroundStyleRaised;
  self.itemImageView.cell.backgroundStyle = NSBackgroundStyleRaised;
  [self.tabView bind:NSSelectedIndexBinding toObject:self withKeyPath:NSStringFromSelector(@selector(activeTab)) options:nil];
  
  NSView *entryView = self.entryViewController.view;
  NSView *groupView = self.groupViewController.view;
  
  
  NSTabViewItem *entryTabItem = [self.tabView tabViewItemAtIndex:MPEntryTab];
  NSView *entryTabView = entryTabItem.view;
  [entryTabView addSubview:entryView];
  NSDictionary *views = NSDictionaryOfVariableBindings(entryView, groupView);
  [entryTabView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[entryView]|" options:0 metrics:nil views:views]];
  [entryTabView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[entryView]|" options:0 metrics:nil views:views]];
  entryTabItem.initialFirstResponder = entryTabView;
  
  NSTabViewItem *groupTabItem = [self.tabView tabViewItemAtIndex:MPGroupTab];
  NSView *groupTabView = groupTabItem.view;
  [groupTabView addSubview:groupView];
  [groupTabView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[groupView]|" options:0 metrics:nil views:views]];
  [groupTabView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[groupView]|" options:0 metrics:nil views:views]];
  groupTabItem.initialFirstResponder = groupView;
  
  [self.view layout];
  
  self.discardChangesButton.hidden = YES;
  self.saveChangesButton.hidden = YES;
}

- (void)registerNotificationsForDocument:(MPDocument *)document {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didChangeCurrentItem:)
                                               name:MPDocumentCurrentItemChangedNotification
                                             object:document];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_willChangeModelProperty:)
                                               name:MPDocumentWillChangeModelPropertyNotification
                                             object:document];
  
  self.entryViewController.observer = document;
  self.itemImageView.modelChangeObserver = document;
  self.observer = document;
  
  [self.entryViewController registerNotificationsForDocument:document];
}

#pragma mark -
#pragma mark Properties
- (void)setActiveTab:(NSUInteger)activeTab {
  if(_activeTab != activeTab) {
    _activeTab = activeTab;
  }
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
  
  self.modifiedTextField.stringValue = [NSString stringWithFormat:modifedAtTemplate, modificationString];
  self.createdTextField.stringValue = [NSString stringWithFormat:createdAtTemplate, creationString];
}

#pragma mark -
#pragma mark Popup
- (IBAction)pickIcon:(id)sender {
  NSAssert([sender isKindOfClass:NSView.class], @"");
  [self _popupViewController:[[MPIconSelectViewController alloc] init] atView:(NSView *)sender];
}

- (IBAction)pickExpiryDate:(id)sender {
  NSAssert([sender isKindOfClass:NSView.class], @"");
  [self _popupViewController:[[MPDatePickingViewController alloc] init] atView:(NSView *)sender];
}

- (IBAction)showPluginData:(id)sender {
  NSAssert([sender isKindOfClass:[NSView class]], @"");
  [self _popupViewController:[[MPPluginDataViewController alloc] init] atView:(NSView *)sender];
}

- (void)_popupViewController:(MPViewController *)vc atView:(NSView *)view {
  if(self.popover) {
    return; // Popover still active, abort
  }
  self.popover = [[NSPopover alloc] init];
  self.popover.delegate = self;
  self.popover.behavior = NSPopoverBehaviorTransient;
  vc.representedObject = self.representedObject;
  vc.observer = self.windowController.document;
  self.popover.contentViewController = vc;
  [self.popover showRelativeToRect:NSZeroRect ofView:view preferredEdge:NSMinYEdge];
}


#pragma mark -
#pragma mark NSPopover Delegate

- (void)popoverDidClose:(NSNotification *)notification {
  /* clear out the popover */
  self.popover = nil;
}

#pragma mark -
#pragma mark MPDocument Notifications
- (void)_willChangeModelProperty:(NSNotification *)notification {
  /* TODO use uuids for pushed item? */
  if(self.didPushHistory) {
    return;
  }
  KPKEntry *entry = [self.representedObject asEntry];
  if( entry ) {
    [entry pushHistory];
    self.didPushHistory = YES;
  }
}

- (void)_didChangeCurrentItem:(NSNotification *)notification {
  MPDocument *document = notification.object;
  KPKNode *node = document.selectedNodes.count == 1 ? document.selectedNodes.firstObject : nil;
  if(node.asGroup) {
    self.activeTab = MPGroupTab;
  }
  else if(node.asEntry) {
    self.activeTab = MPEntryTab;
  }
  else {
    self.activeTab = MPEmptyTab;
  }
  self.didPushHistory = NO;
  
  /* manually commit editing on any active editors */
  [self commitEditing];
  [self.entryViewController commitEditing];
  [self.groupViewController commitEditing];
  
  self.representedObject = node;
  self.itemImageView.node = node;
  self.entryViewController.representedObject = node.asEntry;
  self.groupViewController.representedObject = node.asGroup;
  
}

@end
