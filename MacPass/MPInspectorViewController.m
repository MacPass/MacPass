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

@property (strong) MPIconSelectViewController *iconSelectionViewController;
@property (strong) NSPopover *popover;

@property (nonatomic, strong) NSDate *modificationDate;
@property (nonatomic, strong) NSDate *creationDate;
@property (copy) NSString *expiryDateText;

@property (nonatomic, assign) NSUInteger activeTab;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSSplitView *splitView;
@property (unsafe_unretained) IBOutlet NSTextView *notesTextView;

@property (strong) NSObjectController *nodeController;

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
    self.nodeController = [[NSObjectController alloc] init];
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
  
  self.cancelEditButton.hidden = YES;
  
  [self _establishBindings];
}

- (void)registerNotificationsForDocument:(MPDocument *)document {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didChangeCurrentItem:)
                                               name:MPDocumentCurrentItemChangedNotification
                                             object:document];
  [self.entryViewController registerNotificationsForDocument:document];
  
  [self.entryViewController setupBindings:document];
  [self.groupViewController setupBindings:document];
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
  
  [self.modifiedTextField setStringValue:[NSString stringWithFormat:modifedAtTemplate, modificationString]];
  [self.createdTextField setStringValue:[NSString stringWithFormat:createdAtTemplate, creationString]];
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
  if(!self.iconSelectionViewController) {
    self.iconSelectionViewController = [[MPIconSelectViewController alloc] init];
  }
  [self.iconSelectionViewController reset];
  self.iconSelectionViewController.popover = self.popover;
  self.popover.contentViewController = self.iconSelectionViewController;
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
  MPDatePickingViewController *controller = [[MPDatePickingViewController alloc] init];
  controller.popover = self.popover;
  MPDocument *document = self.windowController.document;
  if(document.selectedItem.timeInfo.expirationDate) {
    controller.date = document.selectedItem.timeInfo.expirationDate;
  }
  self.popover.contentViewController = controller;
  [self.popover showRelativeToRect:NSZeroRect ofView:sender preferredEdge:NSMinYEdge];
}

- (void)popoverDidClose:(NSNotification *)notification {
  NSPopover *popover = [notification object];
  if([popover.contentViewController isKindOfClass:[MPIconSelectViewController class]]) {
    MPIconSelectViewController *viewController = (MPIconSelectViewController *)popover.contentViewController;
    if(!viewController.didCancel) {
      [self _setIcon:viewController.selectedIcon];
    }
  }
  if([popover.contentViewController isKindOfClass:[MPDatePickingViewController class]]) {
    MPDatePickingViewController *viewController = (MPDatePickingViewController *)popover.contentViewController;
    if(!viewController.didCancel) {
      [self _setExpiryDate:viewController.date];
    }
  }
  self.popover = nil;
}

- (void)_setIcon:(NSInteger)iconId {
  MPDocument *document = [[self windowController] document];
  BOOL useDefault = (iconId == -1);
  switch (self.activeTab) {
    case MPGroupTab:
      document.selectedGroup.iconId = useDefault ? [KPKGroup defaultIcon] : iconId;
      break;
      
    case MPEntryTab:
      document.selectedEntry.iconId = useDefault ? [KPKEntry defaultIcon]: iconId;
      break;
      
    default:
      break;
  }
}

- (void)_setExpiryDate:(NSDate *)date {
  MPDocument *document = [[self windowController] document];
  document.selectedItem.timeInfo.expirationDate = date;
}

#pragma mark -
#pragma mark Bindings
- (void)_establishBindings {
  
  [self.itemImageView bind:NSValueBinding
                  toObject:self.nodeController
               withKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(content)), NSStringFromSelector(@selector(iconImage))]
                   options:nil];
  [self.notesTextView bind:NSValueBinding
                  toObject:self.nodeController
               withKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(content)), NSStringFromSelector(@selector(notes))]
                   options:@{ NSNullPlaceholderBindingOption: NSLocalizedString(@"NONE", "")}];
  [self.itemNameTextField bind:NSValueBinding
                      toObject:self.nodeController
                   withKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(content)), NSStringFromSelector(@selector(title))]
                       options:@{NSNullPlaceholderBindingOption: NSLocalizedString(@"NONE", "")}];
}

#pragma mark -
#pragma mark Editing
- (void)_toggleEditors:(BOOL)editable {
  self.itemImageView.enabled = editable;
  self.itemNameTextField.enabled = editable;
  self.itemImageView.enabled = editable;
  self.notesTextView.editable = editable;
}
#pragma mark -
#pragma mark MPDocument Notifications

- (void)_didChangeCurrentItem:(NSNotification *)notification {
  MPDocument *document = notification.object;
  if(document.selectedItem.asGroup) {
    self.activeTab = MPGroupTab;
  }
  else if(document.selectedItem.asEntry) {
    self.activeTab = MPEntryTab;
  }
  else {
    self.activeTab = MPEmptyTab;
  }
  self.nodeController.content = document.selectedItem;
  self.entryViewController.representedObject = document.selectedItem.asEntry;
  self.groupViewController.representedObject = document.selectedItem.asGroup;
}

- (IBAction)beginEditing:(id)sender {
  self.editButton.action = @selector(commitEditing:);
  self.editButton.title = NSLocalizedString(@"SAVE", "");
  self.cancelEditButton.hidden = NO;
  [self _toggleEditors:YES];
}

- (IBAction)cancelEditing:(id)sender {
  self.editButton.title = NSLocalizedString(@"EDIT", "");
  self.cancelEditButton.hidden = YES;
  self.editButton.action = @selector(beginEditing:);
  [self _toggleEditors:NO];
}

- (IBAction)commitEditing:(id)sender {
  [self cancelEditing:sender];
}
@end
