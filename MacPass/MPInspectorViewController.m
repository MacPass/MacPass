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
#import "MPDatePickingViewController.h"

#import "NSDate+Humanized.h"
#import "KPKNode+IconImage.h"

#import "KPKTree.h"
#import "KPKMetaData.h"
#import "KPKGroup.h"
#import "KPKEntry.h"
#import "KPKNode.h"
#import "KPKTimeInfo.h"

#import "HNHGradientView.h"
#import "MPPopupImageView.h"


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
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSResponder *)reconmendedFirstResponder {
  return [self view];
}

- (void)awakeFromNib {
  [self.bottomBar setBorderType:HNHBorderTop|HNHBorderHighlight];
    
  [[self.noSelectionInfo cell] setBackgroundStyle:NSBackgroundStyleRaised];
  [[self.itemImageView cell] setBackgroundStyle:NSBackgroundStyleRaised];
  [self.tabView bind:NSSelectedIndexBinding toObject:self withKeyPath:@"activeTab" options:nil];
  
  NSView *entryView = [self.entryViewController view];
  NSView *groupView = [self.groupViewController view];
  
  
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
  
  [[self view] layout];
  [self _updateBindings:nil];
}

- (void)regsiterNotificationsForDocument:(MPDocument *)document {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didChangeCurrentItem:)
                                               name:MPDocumentCurrentItemChangedNotification
                                             object:document];
  
  [self.entryViewController regsiterNotificationsForDocument:document];
  
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
#pragma mark Click Edit Button
- (void)toggleEdit:(id)sender {
  BOOL didCancel = sender == self.cancelEditButton;
  MPDocument *document = [[self windowController] document];
  
  if(document.selectedItem) {
    
    /* TODO UndoManager handling */
    [self.editButton setTitle:NSLocalizedString(@"EDIT_ITEM", "")];
    [self.cancelEditButton setHidden:YES];
    [self.entryViewController endEditing];
    
    /*
     We need to be carefull to only undo the things we actually changed
     otherwise we undo older actions
     */
    if(didCancel) {
      
    }
    else {
      
    }
  }
  else {
    //[document.selectedItem beginEditSession];
    [self.editButton setTitle:NSLocalizedString(@"SAVE_CHANGES", "")];
    [self.cancelEditButton setHidden:NO];
    [self.entryViewController beginEditing];
  }
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
  if(document.selectedItem.timeInfo.expiryTime) {
    controller.date = document.selectedItem.timeInfo.expiryTime;
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
  document.selectedItem.timeInfo.expiryTime = date;
}

#pragma mark -
#pragma mark Bindings
- (void)_updateBindings:(id)item {
  if(!item) {
    [self.itemNameTextField unbind:NSValueBinding];
    [self.itemNameTextField unbind:NSEnabledBinding];
    [self.itemNameTextField setHidden:YES];
    [self.itemImageView unbind:NSValueBinding];
    [self.itemImageView unbind:NSEnabledBinding];
    [self.itemImageView setHidden:YES];
    [[self.notesTextView enclosingScrollView] setHidden:YES];
    [self.notesTextView unbind:NSValueBinding];
    [self.notesTextView unbind:NSEditableBinding];
    [self.notesTextView setString:@""];
    return;
  }
  
  /* Disable if item is not editable */
  [self.itemNameTextField bind:NSEnabledBinding toObject:item withKeyPath:NSStringFromSelector(@selector(isEditable)) options:nil];
  [self.itemImageView bind:NSEnabledBinding toObject:item withKeyPath:NSStringFromSelector(@selector(isEditable)) options:nil];
  [self.notesTextView bind:NSEditableBinding toObject:item withKeyPath:NSStringFromSelector(@selector(isEditable)) options:nil];
  
  [self.itemImageView bind:NSValueBinding toObject:item withKeyPath:NSStringFromSelector(@selector(iconImage)) options:nil];
  [[self.notesTextView enclosingScrollView] setHidden:NO];
  [self.notesTextView bind:NSValueBinding toObject:item withKeyPath:NSStringFromSelector(@selector(notes)) options:nil];
  if([item respondsToSelector:@selector(title)]) {
    [self.itemNameTextField bind:NSValueBinding toObject:item withKeyPath:NSStringFromSelector(@selector(title)) options:nil];
  }
  else if( [item respondsToSelector:@selector(name)]) {
    [self.itemNameTextField bind:NSValueBinding toObject:item withKeyPath:NSStringFromSelector(@selector(name)) options:nil];
  }
  [self.itemImageView setHidden:NO];
  [self.itemNameTextField setHidden:NO];
}


#pragma mark -
#pragma mark MPDocument Notifications

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
  [self _updateBindings:document.selectedItem];
  
  /* disable the entry text fields whenever the entry selection changes */
  //[self.entryViewController endEditing];
}
@end