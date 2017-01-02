//
//  MPInspectorTabViewController.m
//  MacPass
//
//  Created by Michael Starke on 05.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPInspectorViewController.h"
#import "MPDatePickingViewController.h"
#import "MPDocument.h"
#import "MPEntryInspectorViewController.h"
#import "MPGroupInspectorViewController.h"
#import "MPIconHelper.h"
#import "MPIconSelectViewController.h"
#import "MPNotifications.h"
#import "MPPopupImageView.h"

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
  NSView *entryTabView = [entryTabItem view];
  [entryTabView addSubview:entryView];
  NSDictionary *views = NSDictionaryOfVariableBindings(entryView, groupView);
  [entryTabView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[entryView]|" options:0 metrics:nil views:views]];
  [entryTabView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[entryView]|" options:0 metrics:nil views:views]];
  [entryTabItem setInitialFirstResponder:entryTabView];
  
  NSTabViewItem *groupTabItem = [self.tabView tabViewItemAtIndex:MPGroupTab];
  NSView *groupTabView = [groupTabItem view];
  [groupTabView addSubview:groupView];
  [groupTabView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[groupView]|" options:0 metrics:nil views:views]];
  [groupTabView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[groupView]|" options:0 metrics:nil views:views]];
  [groupTabItem setInitialFirstResponder:groupView];
  
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
  
  [self.entryViewController registerNotificationsForDocument:document];
}

- (void)updateResponderChain {
  [super updateResponderChain];
  [self.groupViewController updateResponderChain];
  [self.entryViewController updateResponderChain];
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
  if(self.popover) {
    return; // There is still a popover so do nothing
  }
  self.popover = [[NSPopover alloc] init];
  self.popover.delegate = self;
  self.popover.behavior = NSPopoverBehaviorTransient;
  MPIconSelectViewController *vc = [[MPIconSelectViewController alloc] init];
  vc.representedObject = self.representedObject;
  vc.popover = self.popover;
  vc.observer = self.windowController.document;
  self.popover.contentViewController = vc;
  [self.popover showRelativeToRect:NSZeroRect ofView:sender preferredEdge:NSMinYEdge];
}

- (IBAction)pickExpiryDate:(id)sender {
  if(self.popover) {
    return; // Popover still active, abort
  }
  NSAssert([sender isKindOfClass:[NSView class]], @"");
  self.popover = [[NSPopover alloc] init];
  self.popover.delegate = self;
  self.popover.behavior = NSPopoverBehaviorTransient;
  MPDatePickingViewController *vc = [[MPDatePickingViewController alloc] init];
  vc.representedObject = self.representedObject;
  vc.observer = self.windowController.document;
  self.popover.contentViewController = vc;
  [self.popover showRelativeToRect:NSZeroRect ofView:sender preferredEdge:NSMinYEdge];
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
  self.entryViewController.representedObject = node.asEntry;
  self.groupViewController.representedObject = node.asGroup;
  
}

@end
