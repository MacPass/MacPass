//
//  MPEntryViewController.m
//  MacPass
//
//  Created by michael starke on 18.02.13.
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

#import "MPEntryViewController.h"
#import "MPAppDelegate.h"
#import "MPOutlineViewController.h"

#import "MPDocument.h"
#import "MPDocumentWindowController.h"

#import "MPPasteBoardController.h"
#import "MPOverlayWindowController.h"
#import "MPContextBarViewController.h"

#import "MPConstants.h"

#import "MPActionHelper.h"
#import "MPContextMenuHelper.h"
#import "MPIconHelper.h"
#import "MPSettingsHelper.h"
#import "MPEntryTableDataSource.h"
#import "MPStringLengthValueTransformer.h"
#import "MPValueTransformerHelper.h"
#import "MPEntryContextMenuDelegate.h"

#import "NSApplication+MPAdditions.h"

#import "KeePassKit/KeePassKit.h"
#import "KPKNode+IconImage.h"

#import "HNHUi/HNHUi.h"

#import "MPNotifications.h"

#define STATUS_BAR_ANIMATION_TIME 0.15
#define EXPIRED_ENTRY_REFRESH_SECONDS 60

NSString *const MPEntryTableIndexColumnIdentifier = @"MPEntryTableIndexColumnIdentifier";
NSString *const MPEntryTableUserNameColumnIdentifier = @"MPUserNameColumnIdentifier";
NSString *const MPEntryTableTitleColumnIdentifier = @"MPTitleColumnIdentifier";
NSString *const MPEntryTablePasswordColumnIdentifier = @"MPPasswordColumnIdentifier";
NSString *const MPEntryTableParentColumnIdentifier = @"MPParentColumnIdentifier";
NSString *const MPEntryTableURLColumnIdentifier = @"MPEntryTableURLColumnIdentifier";
NSString *const MPEntryTableNotesColumnIdentifier = @"MPEntryTableNotesColumnIdentifier";
NSString *const MPEntryTableAttachmentColumnIdentifier = @"MPEntryTableAttachmentColumnIdentifier";
NSString *const MPEntryTableModfiedColumnIdentifier = @"MPEntryTableModfiedColumnIdentifier";
NSString *const MPEntryTableHistoryColumnIdentifier = @"MPEntryTableHistoryColumnIdentifier";

NSString *const _MPTableImageCellView = @"ImageCell";
NSString *const _MPTableStringCellView = @"StringCell";
NSString *const _MPTableSecurCellView = @"PasswordCell";

@interface MPEntryViewController () {
  BOOL _isDisplayingContextBar;
  BOOL _didUnlock;
}

@property (strong) MPContextBarViewController *contextBarViewController;
@property (strong) NSArray *filteredEntries;

@property (weak) IBOutlet NSTableView *entryTable;
@property (assign) MPDisplayMode displayMode;


/* Constraints */
@property (strong) IBOutlet NSLayoutConstraint *tableToTopConstraint;
@property (strong) NSLayoutConstraint *contextBarTopConstraint;

@property (nonatomic, strong) MPEntryTableDataSource *dataSource;

@end

@implementation MPEntryViewController

- (NSString *)nibName {
  return @"EntryView";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self) {
    _isDisplayingContextBar = NO;
    _displayMode = MPDisplayModeEntries;
    _entryArrayController = [[NSArrayController alloc] init];
    _dataSource = [[MPEntryTableDataSource alloc] init];
    _dataSource.viewController = self;
    _contextBarViewController = [[MPContextBarViewController alloc] init];
    [self _setupEntryBindings];
  }
  return self;
}

- (void)dealloc {
  [self.entryTable unbind:NSContentArrayBinding];
  [self.entryArrayController unbind:NSContentArrayBinding];
  [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
  self.view.wantsLayer = YES;
  
  self.entryTable.delegate = self;
  self.entryTable.doubleAction = @selector(_columnDoubleClick:);
  self.entryTable.target = self;
  self.entryTable.floatsGroupRows = NO;
  [self.entryTable registerForDraggedTypes:@[KPKEntryUTI, KPKEntryUUDIUTI]];
  /* First responder notifications */
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(_didBecomFirstResponder:)
                                             name:MPDidActivateViewNotification
                                           object:_entryTable];
  
  /*
   NSView *clipView = self.entryTable.enclosingScrollView.contentView;
   [NSNotificationCenter.defaultCenter addObserver:self
   selector:@selector(_tableDidScroll:)
   name:NSViewBoundsDidChangeNotification
   object:clipView];
   */
  
  [self _setupEntryMenu];
  
  NSTableColumn *parentColumn = self.entryTable.tableColumns[0];
  NSTableColumn *titleColumn = self.entryTable.tableColumns[1];
  NSTableColumn *userNameColumn = self.entryTable.tableColumns[2];
  NSTableColumn *passwordColumn = self.entryTable.tableColumns[3];
  NSTableColumn *urlColumn = self.entryTable.tableColumns[4];
  NSTableColumn *attachmentsColumn = [[NSTableColumn alloc] initWithIdentifier:MPEntryTableAttachmentColumnIdentifier];
  NSTableColumn *notesColumn = [[NSTableColumn alloc] initWithIdentifier:MPEntryTableNotesColumnIdentifier];
  NSTableColumn *modifiedColumn = [[NSTableColumn alloc] initWithIdentifier:MPEntryTableModfiedColumnIdentifier];
  NSTableColumn *historyColumn = [[NSTableColumn alloc] initWithIdentifier:MPEntryTableHistoryColumnIdentifier];
  NSTableColumn *indexColumn = [[NSTableColumn alloc] initWithIdentifier:MPEntryTableIndexColumnIdentifier];
  notesColumn.minWidth = 40.0;
  attachmentsColumn.minWidth = 40.0;
  modifiedColumn.minWidth = 40.0;
  historyColumn.minWidth = 40.0;
  indexColumn.minWidth = 27.0;
  indexColumn.maxWidth = 27.0;
  [self.entryTable addTableColumn:notesColumn];
  [self.entryTable addTableColumn:attachmentsColumn];
  [self.entryTable addTableColumn:modifiedColumn];
  [self.entryTable addTableColumn:historyColumn];
  [self.entryTable addTableColumn:indexColumn];
  
  parentColumn.identifier = MPEntryTableParentColumnIdentifier;
  titleColumn.identifier = MPEntryTableTitleColumnIdentifier;
  userNameColumn.identifier = MPEntryTableUserNameColumnIdentifier;
  passwordColumn.identifier = MPEntryTablePasswordColumnIdentifier;
  urlColumn.identifier = MPEntryTableURLColumnIdentifier;
  
  self.entryTable.autosaveName = @"EntryTable";
  self.entryTable.autosaveTableColumns = YES;
  
  NSString *parentTitleKeyPath = [[NSString alloc] initWithFormat:@"%@.%@", NSStringFromSelector(@selector(parent)), NSStringFromSelector(@selector(title))];
  NSString *timeInfoModificationTimeKeyPath = [[NSString alloc] initWithFormat:@"%@.%@", NSStringFromSelector(@selector(timeInfo)), NSStringFromSelector(@selector(modificationDate))];
  
  indexColumn.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(index)) ascending:YES selector:@selector(compare:)];
  titleColumn.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(title))ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
  userNameColumn.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(username)) ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
  urlColumn.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(url)) ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
  parentColumn.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:parentTitleKeyPath ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
  modifiedColumn.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:timeInfoModificationTimeKeyPath ascending:YES selector:@selector(compare:)];
  
  indexColumn.headerCell.stringValue = @"";
  indexColumn.headerToolTip = NSLocalizedString(@"ENTRY_INDEX_COLUMN_TOOLTIP", "Tooltip displayed on the index header cell");
  parentColumn.headerCell.stringValue = NSLocalizedString(@"GROUP", "Group column title");
  titleColumn.headerCell.stringValue = NSLocalizedString(@"TITLE", "Title column title");
  userNameColumn.headerCell.stringValue = NSLocalizedString(@"USERNAME", "Username column title");
  passwordColumn.headerCell.stringValue = NSLocalizedString(@"PASSWORD", "Password column title");
  urlColumn.headerCell.stringValue = NSLocalizedString(@"URL", "Url column title");
  notesColumn.headerCell.stringValue = NSLocalizedString(@"NOTES", "Notes column title");
  attachmentsColumn.headerCell.stringValue = NSLocalizedString(@"ATTACHMENTS", "Attachments column title (shows counts)");
  modifiedColumn.headerCell.stringValue = NSLocalizedString(@"MODIFIED", "Modification date column title");
  historyColumn.headerCell.stringValue = NSLocalizedString(@"HISTORY", "History count column title");
  
  [self.entryTable bind:NSContentBinding toObject:self.entryArrayController withKeyPath:NSStringFromSelector(@selector(arrangedObjects)) options:nil];
  [self.entryTable bind:NSSortDescriptorsBinding toObject:self.entryArrayController withKeyPath:NSStringFromSelector(@selector(sortDescriptors)) options:nil];
  [self.entryTable bind:NSSelectionIndexesBinding toObject:self.entryArrayController withKeyPath:NSStringFromSelector(@selector(selectionIndexes)) options:nil];
  self.entryTable.dataSource = self.dataSource;
  
  // bind NSArrayController sorting so that sort order gets auto-saved
  // see: http://simx.me/technonova/software_development/sort_descriptors_nstableview_bindings_a.html
  [self.entryArrayController bind:NSSortDescriptorsBinding
                         toObject:[NSUserDefaultsController sharedUserDefaultsController]
                      withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyEntryTableSortDescriptors]
                          options:@{ NSValueTransformerNameBindingOption: NSUnarchiveFromDataTransformerName }];
  
  [self _setupHeaderMenu];
  /* Move index and parent column to dedicated places if it was moved by the user before */
  parentColumn.hidden = YES;
  NSUInteger indexIndex = [self.entryTable columnWithIdentifier:MPEntryTableIndexColumnIdentifier];
  if(indexIndex != 0) {
    [self.entryTable moveColumn:indexIndex toColumn:0];
  }
  NSUInteger parentIndex = [self.entryTable columnWithIdentifier:MPEntryTableParentColumnIdentifier];
  if(parentIndex != 1) {
    [self.entryTable moveColumn:parentIndex toColumn:1];
  }
}

- (NSResponder *)reconmendedFirstResponder {
  return self.entryTable;
}

- (void)registerNotificationsForDocument:(MPDocument *)document {
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didChangeCurrentItem:) name:MPDocumentCurrentItemChangedNotification object:document];
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didAddItem:) name:MPDocumentDidAddEntryNotification object:document];
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didEnterSearch:) name:MPDocumentDidEnterSearchNotification object:document];
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didExitSearch:) name:MPDocumentDidExitSearchNotification object:document];
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didUpdateSearchResults:) name:MPDocumentDidChangeSearchResults object:document];
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_showEntryHistory:) name:MPDocumentShowEntryHistoryNotification object:document];
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_hideEntryHistory:) name:MPDocumentHideEntryHistoryNotification object:document];
    
  [self.contextBarViewController registerNotificationsForDocument:document];
}

#pragma mark NSTableViewDelgate

- (void)_tableDidScroll:(NSNotification *)notification {
  if(self.displayMode != MPDisplayModeEntries) {
    return; // Only update on entry display
  }
  
  NSView *clipView = notification.object;
  if(nil == clipView || self.entryTable.enclosingScrollView.contentView != clipView) {
    return; // Wrong view
  }
  /* padding to compensate for clipped items */
  CGPoint point = CGPointMake(clipView.bounds.origin.x, clipView.bounds.origin.y + self.entryTable.headerView.frame.size.height);
  NSInteger topRow = [self.entryTable rowAtPoint:point];
  
  if(topRow > -1) {
    KPKEntry *entry = self.entryArrayController.arrangedObjects[topRow];
    entry.parent.lastTopVisibleEntry = entry.uuid;
  }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  BOOL isTitleColumn = [tableColumn.identifier isEqualToString:MPEntryTableTitleColumnIdentifier];
  BOOL isGroupColumn = [tableColumn.identifier isEqualToString:MPEntryTableParentColumnIdentifier];
  BOOL isPasswordColum = [tableColumn.identifier isEqualToString:MPEntryTablePasswordColumnIdentifier];
  BOOL isUsernameColumn = [tableColumn.identifier isEqualToString:MPEntryTableUserNameColumnIdentifier];
  BOOL isURLColumn = [tableColumn.identifier isEqualToString:MPEntryTableURLColumnIdentifier];
  BOOL isAttachmentColumn = [tableColumn.identifier isEqualToString:MPEntryTableAttachmentColumnIdentifier];
  BOOL isNotesColumn = [tableColumn.identifier isEqualToString:MPEntryTableNotesColumnIdentifier];
  BOOL isModifedColumn = [tableColumn.identifier isEqualToString:MPEntryTableModfiedColumnIdentifier];
  BOOL isHistoryColumn = [tableColumn.identifier isEqualToString:MPEntryTableHistoryColumnIdentifier];
  
  NSTableCellView *view = nil;
  if(isTitleColumn || isGroupColumn) {
    view = [tableView makeViewWithIdentifier:_MPTableImageCellView owner:self];
    [view.textField unbind:NSValueBinding];
    [view.imageView unbind:NSValueBinding];
    if( isTitleColumn ) {
      NSString *titleKeyPath = [NSString stringWithFormat:@"%@.%@",
                                NSStringFromSelector(@selector(objectValue)),
                                NSStringFromSelector(@selector(title))];
      NSString *iconImageKeyPath = [NSString stringWithFormat:@"%@.%@",
                                    NSStringFromSelector(@selector(objectValue)),
                                    NSStringFromSelector(@selector(iconImage))];
      [view.textField bind:NSValueBinding toObject:view withKeyPath:titleKeyPath options:nil];
      [view.imageView bind:NSValueBinding toObject:view withKeyPath:iconImageKeyPath options:nil];
    }
    else {
      KPKEntry *entry = self.entryArrayController.arrangedObjects[row];
      NSAssert(entry.parent != nil, @"Entry needs to have a parent");
      
      NSString *parentTitleKeyPath = [NSString stringWithFormat:@"%@.%@.%@",
                                      NSStringFromSelector(@selector(objectValue)),
                                      NSStringFromSelector(@selector(parent)),
                                      NSStringFromSelector(@selector(title))];
      NSString *parentIconImageKeyPath = [NSString stringWithFormat:@"%@.%@.%@",
                                          NSStringFromSelector(@selector(objectValue)),
                                          NSStringFromSelector(@selector(parent)),
                                          NSStringFromSelector(@selector(iconImage))];
      [view.textField bind:NSValueBinding toObject:view withKeyPath:parentTitleKeyPath options:nil];
      [view.imageView bind:NSValueBinding toObject:view withKeyPath:parentIconImageKeyPath options:nil];
    }
  }
  else if(isPasswordColum) {
    view = [tableView makeViewWithIdentifier:_MPTableSecurCellView owner:self];
    NSString *passwordKeyPath = [NSString stringWithFormat:@"%@.%@",
                                 NSStringFromSelector(@selector(objectValue)),
                                 NSStringFromSelector(@selector(password))];
    NSDictionary *options = @{ NSValueTransformerBindingOption : [NSValueTransformer valueTransformerForName:MPStringLengthValueTransformerName] };
    [view.textField bind:NSValueBinding toObject:view withKeyPath:passwordKeyPath options:options];
  }
  else  {
    view = [tableView makeViewWithIdentifier:_MPTableStringCellView owner:self];
    [view.textField unbind:NSValueBinding];
    view.textField.stringValue = @"";
    if(!isModifedColumn) {
      /* clean up old formatter that might be left */
      view.textField.formatter = nil;
    }
    
    if(isModifedColumn) {
      if(!view.textField.formatter) {
        /* Just use one formatter instance since it's expensive to create */
        static NSDateFormatter *formatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
          formatter = [[NSDateFormatter alloc] init];
          formatter.dateStyle = NSDateFormatterMediumStyle;
          formatter.timeStyle = NSDateFormatterMediumStyle;
        });
        view.textField.formatter = formatter;
      }
      NSString *modificationTimeKeyPath = [NSString stringWithFormat:@"%@.%@.%@",
                                           NSStringFromSelector(@selector(objectValue)),
                                           NSStringFromSelector(@selector(timeInfo)),
                                           NSStringFromSelector(@selector(modificationDate))];
      
      [view.textField bind:NSValueBinding toObject:view withKeyPath:modificationTimeKeyPath options:nil];
      return view;
    }
    else if(isURLColumn) {
      NSString *urlKeyPath = [NSString stringWithFormat:@"%@.%@",
                              NSStringFromSelector(@selector(objectValue)),
                              NSStringFromSelector(@selector(url))];
      [view.textField bind:NSValueBinding toObject:view withKeyPath:urlKeyPath options:nil];
    }
    else if(isUsernameColumn) {
      NSString *usernameKeyPath = [NSString stringWithFormat:@"%@.%@",
                                   NSStringFromSelector(@selector(objectValue)),
                                   NSStringFromSelector(@selector(username))];
      
      [view.textField bind:NSValueBinding toObject:view withKeyPath:usernameKeyPath options:nil];
    }
    else if(isNotesColumn) {
      NSDictionary *options = @{ NSValueTransformerNameBindingOption : MPStripLineBreaksTransformerName };
      NSString *notesKeyPath = [NSString stringWithFormat:@"%@.%@",
                                NSStringFromSelector(@selector(objectValue)),
                                NSStringFromSelector(@selector(notes))];
      [view.textField bind:NSValueBinding toObject:view withKeyPath:notesKeyPath options:options];
    }
    else if(isAttachmentColumn) {
      NSString *binariesCountKeyPath = [NSString stringWithFormat:@"%@.%@.@count",
                                        NSStringFromSelector(@selector(objectValue)),
                                        NSStringFromSelector(@selector(binaries))];
      [view.textField bind:NSValueBinding toObject:view withKeyPath:binariesCountKeyPath options:nil];
    }
    else if(isHistoryColumn) {
      NSString *historyCountKeyPath = [NSString stringWithFormat:@"%@.%@.@count",
                                       NSStringFromSelector(@selector(objectValue)),
                                       NSStringFromSelector(@selector(history))];
      [view.textField bind:NSValueBinding toObject:view withKeyPath:historyCountKeyPath options:nil];
    }
  }
  return view;
}

- (void)tableView:(NSTableView *)tableView didRemoveRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
  /* Rows being removed for data change should be checked here to clear selections */
  if(row == -1) {
    /* post selection change notification since cocoa decides not to post them if a selected row is removed */
    [self tableViewSelectionDidChange:[NSNotification notificationWithName:NSTableViewSelectionDidChangeNotification object:tableView]];
  }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  NSTableView *tableView = notification.object;
  if(tableView != self.entryTable) {
    return; // Not the right table view
  }
  MPDocument *document = self.windowController.document;
  document.selectedEntries = self.entryArrayController.selectedObjects;
}

- (BOOL)tableView:(NSTableView *)tableView shouldReorderColumn:(NSInteger)columnIndex toColumn:(NSInteger)newColumnIndex {
  NSTableColumn *column = tableView.tableColumns[columnIndex];
  /* Do not allow to set as first column */
  
  if(newColumnIndex == 1 || newColumnIndex == 0) {
    return NO;
  }
  BOOL isParentColumn = [column.identifier isEqualToString:MPEntryTableParentColumnIdentifier];
  BOOL isIndexColumn = [column.identifier isEqualToString:MPEntryTableIndexColumnIdentifier];
  return !(isParentColumn || isIndexColumn);
}

#pragma mark MPTargetItemResolving
- (NSArray<KPKEntry *> *)currentTargetEntries {
  NSInteger activeRow = self.entryTable.clickedRow;
  if(activeRow > -1 && activeRow < [self.entryArrayController.arrangedObjects count]) {
    if(![self.entryArrayController.selectionIndexes containsIndex:activeRow]) {
      return @[ self.entryArrayController.arrangedObjects[activeRow] ];
    }
  }
  return self.entryArrayController.selectedObjects;
}

- (NSArray<KPKNode *> *)currentTargetNodes {
  NSArray *entries = self.currentTargetEntries;
  if(entries.count > 0) {
    return entries;
  }
  MPDocument *document = self.windowController.document;
  return document.selectedNodes;
}

#pragma mark MPDocument Notifications
- (void)_didChangeCurrentItem:(NSNotification *)notification {
  MPDocument *document = notification.object;
  
  if(document.selectedGroups.count != 1) {
    if(self.displayMode == MPDisplayModeEntries) {
      /* no group selection out for entry display is wrong */
      self.representedObject = nil;
      return;
    }
  }
  /*
   If a group is the current item, see if we already show that group
   also test if an element has been selected (issue #257)
   */
  if(document.selectedNodes.firstObject == document.selectedGroups.firstObject && document.selectedNodes.count > 0) {
    switch(self.displayMode) {
        
      case MPDisplayModeSearchResults:
        [document exitSearch:nil];
        break;
      case MPDisplayModeHistory:
        [document hideEntryHistory:nil];
        break;
      case MPDisplayModeEntries:
        if([self.entryArrayController.content count] > 0) {
          KPKEntry *entry = [self.entryArrayController.content lastObject];
          if(entry.parent == document.selectedGroups.lastObject) {
            return; // we are showing the correct object right now.
          }
          break;
        }
    }
    self.representedObject = document.selectedGroups.count == 1 ? document.selectedGroups.lastObject : nil;
  }
  [self _updateContextBar];
}

- (void)_didBecomFirstResponder:(NSNotification *)notification {
  MPDocument *document =   self.windowController.document;
  document.selectedEntries = self.entryArrayController.selectedObjects;
}

- (void)_didAddItem:(NSNotification *)notification {
  MPDocument *document = notification.object;
  // FIXME: UI should know search state not document!
  if(document.hasSearch) {
    return; // Search should not react to new Entries as it's displaying search results
  }
  NSDictionary *dict = notification.userInfo;
  KPKEntry *entry = dict[MPDocumentEntryKey];
  NSUInteger row = [self.entryArrayController.arrangedObjects indexOfObject:entry];
  [self.entryTable scrollRowToVisible:row];
  [self.entryTable selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void)_didUpdateSearchResults:(NSNotification *)notification {
  NSArray *result = notification.userInfo[kMPDocumentSearchResultsKey];
  NSAssert(result != nil, @"Resutls should never be nil");
  self.filteredEntries = result;
  self.entryArrayController.content = self.filteredEntries;
  [self.entryTable tableColumnWithIdentifier:MPEntryTableParentColumnIdentifier].hidden = NO;
  [self _updateContextBar];
}


- (void)_didExitSearch:(NSNotification *)notification {
  [self.entryTable tableColumnWithIdentifier:MPEntryTableParentColumnIdentifier].hidden = YES;
  self.entryArrayController.content = nil;
  self.filteredEntries = nil;
  self.displayMode = MPDisplayModeEntries;
  [self _updateContextBar];
  MPDocument *document = notification.object;
  document.selectedGroups = document.selectedGroups;
}

- (void)_didEnterSearch:(NSNotification *)notification {
  self.displayMode = MPDisplayModeSearchResults;
  [self _updateContextBar];
}

- (void)_showEntryHistory:(NSNotification *)notification {
  self.displayMode = MPDisplayModeHistory;
  KPKEntry *entry = notification.userInfo[MPDocumentEntryKey];
  NSAssert(entry != nil, @"Resutls should never be nil");
  [self.entryArrayController bind:NSContentArrayBinding toObject:entry withKeyPath:NSStringFromSelector(@selector(history)) options:nil];
  [self _updateContextBar];
}

- (void)_hideEntryHistory:(NSNotification *)notification {
  self.displayMode = MPDisplayModeEntries;
  [self _setupEntryBindings];
  self.entryArrayController.content = nil;
  [self _updateContextBar];
  MPDocument *document = notification.object;
  document.selectedGroups = document.selectedGroups;
}
#pragma mark ContextBar
- (void)_updateContextBar {
  switch(self.displayMode) {
    case MPDisplayModeSearchResults:
    case MPDisplayModeHistory:
      [self _showContextBar];
      break;
    case MPDisplayModeEntries: {
      NSArray<KPKGroup *> *groups = [self.windowController.document selectedGroups];
      if(groups.count == 1 && groups.firstObject.isTrash) {
        [self _showContextBar];
      }
      else {
        [self _hideContextBar];
      }
    }
  }
}

- (void)_setupEntryBindings {
  NSString *entriesKeyPath = [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), KPKEntriesArrayBinding];
  [self.entryArrayController bind:NSContentArrayBinding toObject:self withKeyPath:entriesKeyPath options:@{NSNullPlaceholderBindingOption: @[]}];
}

- (void)_showContextBar {
  if(_isDisplayingContextBar) {
    return;
  }
  _isDisplayingContextBar = YES;
  if(!self.contextBarViewController.view.superview) {
    [self.view addSubview:self.contextBarViewController.view];
    NSView *contextBar = self.contextBarViewController.view;
    NSView *scrollView = self.entryTable.enclosingScrollView;
    NSDictionary *views = NSDictionaryOfVariableBindings(scrollView, contextBar);
    
    /* Pin to the left */
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contextBar]|" options:0 metrics:nil views:views]];
    /* Pin height and to top of entry table */
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contextBar(==30)]-0-[scrollView]" options:0 metrics:nil views:views]];
    /* Create the top constraint for the filter bar where we can change the constant instead of removing/adding constraints all the time */
    self.contextBarTopConstraint = [NSLayoutConstraint constraintWithItem:contextBar
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1
                                                                 constant:-31];
  }
  /* Add the view for the first time */
  [self.view removeConstraint:self.tableToTopConstraint];
  [self.view addConstraint:self.contextBarTopConstraint];
  [self.view layout];
  self.contextBarTopConstraint.constant = 0;
  
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext* context) {
    context.duration = STATUS_BAR_ANIMATION_TIME;
    context.allowsImplicitAnimation = YES;
    [self.view layoutSubtreeIfNeeded];
  } completionHandler:nil];
}

- (void)_hideContextBar {
  if(!_isDisplayingContextBar) {
    return; // nothing to do;
  }
  self.contextBarTopConstraint.constant = -31;
  [self.view addConstraint:self.tableToTopConstraint];
  
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext* context) {
    context.duration = STATUS_BAR_ANIMATION_TIME;
    context.allowsImplicitAnimation = YES;
    [self.view layoutSubtreeIfNeeded];
  } completionHandler:^{
    self->_isDisplayingContextBar = NO;
  }];
}

#pragma mark Validation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  /* Validation is solely handled in the document */
  return [self.windowController.document validateMenuItem:menuItem];
}

#pragma mark ContextMenu
- (void)_setupEntryMenu {
  
  NSMenu *menu = [[NSMenu alloc] init];
  NSArray *items = [MPContextMenuHelper contextMenuItemsWithItems:MPContextMenuFull|MPContextMenuShowGroupInOutline];
  for(NSMenuItem *item in items) {
    [menu addItem:item];
  }
  menu.delegate = NSApp.mp_delegate.itemActionMenuDelegate;
  self.entryTable.menu = menu;
}

- (void)_setupHeaderMenu {
  NSMenu *headerMenu = [[NSMenu alloc] init];
  
  [headerMenu addItemWithTitle:NSLocalizedString(@"TITLE", "Menu item to toggle display of title column in entry table") action:NULL keyEquivalent:@""];
  [headerMenu addItemWithTitle:NSLocalizedString(@"USERNAME", "Menu item to toggle display of username column in entry table") action:NULL keyEquivalent:@""];
  [headerMenu addItemWithTitle:NSLocalizedString(@"PASSWORD", "Menu item to toggle display of password column in entry table") action:NULL keyEquivalent:@""];
  [headerMenu addItemWithTitle:NSLocalizedString(@"URL", "Menu item to toggle display of url column in entry table") action:NULL keyEquivalent:@""];
  [headerMenu addItemWithTitle:NSLocalizedString(@"NOTES", "Menu item to toggle display of notes column in entry table") action:NULL keyEquivalent:@""];
  [headerMenu addItemWithTitle:NSLocalizedString(@"ATTACHMENTS", "Menu item to toggle display of attachment count column in entry table") action:NULL keyEquivalent:@""];
  [headerMenu addItemWithTitle:NSLocalizedString(@"MODIFIED", "Menu item to toggle display of modified date column in entry table") action:NULL keyEquivalent:@""];
  [headerMenu addItemWithTitle:NSLocalizedString(@"HISTORY", "Menu item to toggle display of history count column in entry table") action:NULL keyEquivalent:@""];
  
  NSArray *identifier = @[ MPEntryTableTitleColumnIdentifier,
                           MPEntryTableUserNameColumnIdentifier,
                           MPEntryTablePasswordColumnIdentifier,
                           MPEntryTableURLColumnIdentifier,
                           MPEntryTableNotesColumnIdentifier,
                           MPEntryTableAttachmentColumnIdentifier,
                           MPEntryTableModfiedColumnIdentifier,
                           MPEntryTableHistoryColumnIdentifier ];
  
  NSDictionary *options = @{ NSValueTransformerNameBindingOption : NSNegateBooleanTransformerName };
  for(NSMenuItem *item in headerMenu.itemArray) {
    NSUInteger index = [headerMenu indexOfItem:item];
    NSTableColumn *column= [self.entryTable tableColumnWithIdentifier:identifier[index]];
    [item bind:NSValueBinding toObject:column withKeyPath:NSHiddenBinding options:options];
  }
  
  self.entryTable.headerView.menu = headerMenu;
}

#pragma mark Actions
- (void)copyPassword:(id)sender {
  NSArray *nodes = self.currentTargetNodes;
  KPKEntry *selectedEntry = nodes.count == 1 ? [nodes.firstObject asEntry] : nil;
  NSString *value = [selectedEntry.password kpk_finalValueForEntry:selectedEntry];
  if(value) {
    [MPPasteBoardController.defaultController copyObjects:@[value] overlayInfo:MPPasteboardOverlayInfoPassword name:nil atView:self.view];
  }
}

- (void)copyUsername:(id)sender {
  NSArray *nodes = self.currentTargetNodes;
  KPKEntry *selectedEntry = nodes.count == 1 ? [nodes.firstObject asEntry] : nil;
  NSString *value = [selectedEntry.username kpk_finalValueForEntry:selectedEntry];
  if(value) {
    [MPPasteBoardController.defaultController copyObjects:@[value] overlayInfo:MPPasteboardOverlayInfoUsername name:nil atView:self.view];
  }
}

- (void)copyCustomAttribute:(id)sender {
  NSArray *nodes = self.currentTargetNodes;
  KPKEntry *selectedEntry = nodes.count == 1 ? [nodes.firstObject asEntry] : nil;
  if(selectedEntry && [selectedEntry isKindOfClass:[KPKEntry class]]) {
    NSUInteger index = [sender tag];
    NSAssert((index >= 0)  && (index < selectedEntry.customAttributes.count), @"Index for custom field needs to be valid");
    KPKAttribute *attribute = selectedEntry.customAttributes[index];
    NSString *value = attribute.evaluatedValue;
    if(value) {
      [MPPasteBoardController.defaultController copyObjects:@[value] overlayInfo:MPPasteboardOverlayInfoCustom name:attribute.key atView:self.view];
    }
  }
}

- (void)copyURL:(id)sender {
  NSArray *nodes = self.currentTargetNodes;
  KPKEntry *selectedEntry = nodes.count == 1 ? [nodes.firstObject asEntry] : nil;
  NSString *value = [selectedEntry.url kpk_finalValueForEntry:selectedEntry];
  if(value) {
    [MPPasteBoardController.defaultController copyObjects:@[value] overlayInfo:MPPasteboardOverlayInfoURL name:nil atView:self.view];
  }
}

- (void)openURL:(id)sender {
  NSArray *nodes = [self currentTargetNodes];
  KPKEntry *selectedEntry = nodes.count == 1 ? [nodes.firstObject asEntry] : nil;
  NSString *expandedURL = [selectedEntry.url kpk_finalValueForEntry:selectedEntry];
  if(expandedURL.length > 0) {
    NSURL *webURL = [NSURL URLWithString:expandedURL];
    NSString *scheme = webURL.scheme;
    if(!scheme) {
      webURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", expandedURL]];
    }
    
    NSString *browserBundleID = [NSUserDefaults.standardUserDefaults stringForKey:kMPSettingsKeyBrowserBundleId];
    NSURL *browserApplicationURL = browserBundleID ? [NSWorkspace.sharedWorkspace URLForApplicationWithBundleIdentifier:browserBundleID] : nil;
    BOOL openedURL = NO;
    
    if(browserApplicationURL) {
      NSRunningApplication *urlOpeningApplication = [NSWorkspace.sharedWorkspace openURLs:@[webURL] withApplicationAtURL:browserApplicationURL options:NSWorkspaceLaunchDefault configuration:@{} error:nil];
      openedURL = nil != urlOpeningApplication;
    }
    
    if(!openedURL) {
      openedURL = [NSWorkspace.sharedWorkspace openURL:webURL];
    }
    if(!openedURL) {
      NSLog(@"Unable to open URL %@", webURL);
    }
  }
}

- (void)copyAsReference:(id)sender {
  NSDictionary *references = @{  kKPKReferenceURLKey: NSLocalizedString(@"COPIED_URL_REFERENCE", "Context menu that copies reference to URL"),
                                 kKPKReferenceNotesKey: NSLocalizedString(@"COPIED_NOTES_REFERENCE", "Context menu that copies reference to note"),
                                 kKPKReferenceTitleKey: NSLocalizedString(@"COPIED_TITLE_REFERENCE", "Context menu that copies reference to title"),
                                 kKPKReferencePasswordKey: NSLocalizedString(@"COPIED_PASSWORD_REFERENCE", "Context menu that copies reference to password"),
                                 kKPKReferenceUsernameKey: NSLocalizedString(@"COPIED_USERNAME_REFERENCE", "Context menu that copies reference to username"),
                                 };
  if(![sender isKindOfClass:NSMenuItem.class]) {
    return;
  }
  NSString *referencesField = [sender representedObject];
  NSArray *nodes = [self currentTargetNodes];
  KPKEntry *selectedEntry = nodes.count == 1 ? [nodes.firstObject asEntry] : nil;
  if(referencesField && selectedEntry) {
    NSString *value = [NSString stringWithFormat:@"{%@%@@%@:%@}", kKPKReferencePrefix, referencesField, kKPKReferenceUUIDKey, selectedEntry.uuid.UUIDString];
    [MPPasteBoardController.defaultController copyObjects:@[value] overlayInfo:MPPasteboardOverlayInfoReference name:references[referencesField] atView:self.view];
  }
}

- (void)delete:(id)sender {
  NSArray *entries = self.currentTargetEntries;
  MPDocument *document = self.windowController.document;
  for(KPKEntry *entry in entries) {
    [document deleteNode:entry];
  }
}

- (void)revertToHistoryEntry:(id)sender {
  MPDocument *document = self.windowController.document;
  NSArray<KPKEntry *> *historyEntries = self.currentTargetEntries;
  if(historyEntries.count != 1) {
    return;
  }
  [document revertEntry:document.historyEntry toEntry:historyEntries.firstObject];
}

- (void)_columnDoubleClick:(id)sender {
  if(0 == [self.entryArrayController.arrangedObjects count]) {
    return; // No data available
  }
  NSInteger columnIndex = self.entryTable.clickedColumn;
  if(columnIndex < 0 || columnIndex >= self.entryTable.tableColumns.count) {
    return; // No Column to use
  }
  NSTableColumn *column = self.entryTable.tableColumns[columnIndex];
  NSString *identifier = column.identifier;
  if([identifier isEqualToString:MPEntryTableTitleColumnIdentifier]) {
    [self _executeTitleColumnDoubleClick];
  }
  else if([identifier isEqualToString:MPEntryTablePasswordColumnIdentifier]) {
    [self copyPassword:nil];
  }
  else if([identifier isEqualToString:MPEntryTableUserNameColumnIdentifier]) {
    [self copyUsername:nil];
  }
  else if([identifier isEqualToString:MPEntryTableURLColumnIdentifier]) {
    [self _executeURLColumnDoubleClick];
  }
  else if([identifier isEqualToString:MPEntryTableParentColumnIdentifier]) {
    [self _executeGroupColumnDoubleClick];
  }
  // TODO: Add more actions for new columns
}

- (void)_executeGroupColumnDoubleClick {
  id target = [NSApp targetForAction:@selector(showGroupInOutline:)];
  [target showGroupInOutline:self];
}

- (void)_executeTitleColumnDoubleClick {
  MPDoubleClickTitleAction action = [NSUserDefaults.standardUserDefaults integerForKey:kMPSettingsKeyDoubleClickTitleAction];
  switch(action) {
    case MPDoubleClickTitleActionInspect:
      [(MPDocumentWindowController *)self.windowController showInspector:nil];
      break;
    case MPDoubleClickTitleActionIgnore:
      break;
    default:
      NSLog(@"Unknown double click title action");
      break;
  }
}
- (void)_executeURLColumnDoubleClick {
  MPDoubleClickURLAction action = [NSUserDefaults.standardUserDefaults integerForKey:kMPSettingsKeyDoubleClickURLAction];
  switch (action) {
    case MPDoubleClickURLActionOpen:
      [self openURL:nil];
      break;
    case MPDoubleClickURLActionCopy:
      [self copyURL:nil];
      break;
    default:
      NSLog(@"Unknown double click URL action");
      break;
  }
}

@end
