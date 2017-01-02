//
//  MPEntryViewController.m
//  MacPass
//
//  Created by michael starke on 18.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
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

#import "KeePassKit/KeePassKit.h"
#import "KPKNode+IconImage.h"

#import "HNHUi/HNHUi.h"

#import "MPNotifications.h"

#define STATUS_BAR_ANIMATION_TIME 0.15
#define EXPIRED_ENTRY_REFRESH_SECONDS 60

typedef NS_ENUM(NSUInteger,MPOVerlayInfoType) {
  MPOverlayInfoPassword,
  MPOverlayInfoUsername,
  MPOverlayInfoURL,
  MPOverlayInfoCustom,
};

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
  /* TODO unify delegation */
  MPEntryContextMenuDelegate *_menuDelegate;
  BOOL _isDisplayingContextBar;
  BOOL _didUnlock;
}

@property (strong) MPContextBarViewController *contextBarViewController;
@property (strong) NSArray *filteredEntries;

@property (weak) IBOutlet NSTableView *entryTable;

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
    _entryArrayController = [[NSArrayController alloc] init];
    _dataSource = [[MPEntryTableDataSource alloc] init];
    _dataSource.viewController = self;
    _menuDelegate = [[MPEntryContextMenuDelegate alloc] init];
    _contextBarViewController = [[MPContextBarViewController alloc] init];
    NSString *entriesKeyPath = [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(entries))];
    [_entryArrayController bind:NSContentBinding toObject:self withKeyPath:entriesKeyPath options:nil];
  }
  return self;
}

- (void)dealloc {
  [self.entryTable unbind:NSContentArrayBinding];
  [self.entryArrayController unbind:NSContentArrayBinding];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didLoadView {
  self.view.wantsLayer = YES;
  
  self.entryTable.delegate = self;
  self.entryTable.doubleAction = @selector(_columnDoubleClick:);
  self.entryTable.target = self;
  self.entryTable.floatsGroupRows = NO;
  [self.entryTable registerForDraggedTypes:@[KPKEntryUTI]];
  /* First responder notifications */
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didBecomFirstResponder:)
                                               name:MPDidActivateViewNotification
                                             object:_entryTable];
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
  indexColumn.minWidth = 16.0;
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
  parentColumn.headerCell.stringValue = NSLocalizedString(@"GROUP", "");
  titleColumn.headerCell.stringValue = NSLocalizedString(@"TITLE", "");
  userNameColumn.headerCell.stringValue = NSLocalizedString(@"USERNAME", "");
  passwordColumn.headerCell.stringValue = NSLocalizedString(@"PASSWORD", "");
  urlColumn.headerCell.stringValue = NSLocalizedString(@"URL", "");
  notesColumn.headerCell.stringValue = NSLocalizedString(@"NOTES", "");
  attachmentsColumn.headerCell.stringValue = NSLocalizedString(@"ATTACHMENTS", "");
  modifiedColumn.headerCell.stringValue = NSLocalizedString(@"MODIFIED", "");
  historyColumn.headerCell.stringValue = NSLocalizedString(@"HISTORY", "");
  
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
  parentColumn.hidden = YES;
}

- (NSResponder *)reconmendedFirstResponder {
  return self.entryTable;
}

- (void)regsiterNotificationsForDocument:(MPDocument *)document {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didChangeCurrentItem:)
                                               name:MPDocumentCurrentItemChangedNotification
                                             object:document];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didAddItem:)
                                               name:MPDocumentDidAddEntryNotification
                                             object:document];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didEnterSearch:)
                                               name:MPDocumentDidEnterSearchNotification
                                             object:document];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didExitSearch:)
                                               name:MPDocumentDidExitSearchNotification
                                             object:document];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didUpdateSearchResults:)
                                               name:MPDocumentDidChangeSearchResults
                                             object:document];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didUnlockDatabase:)
                                               name:MPDocumentDidUnlockDatabaseNotification
                                             object:document];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didEnterHistory:) name:MPDocumentDidEnterHistoryNotification object:document];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didExitHistory:) name:MPDocumentDidExitHistoryNotification object:document];
  
  [self.contextBarViewController registerNotificationsForDocument:document];
}

#pragma mark NSTableViewDelgate

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
  /*
   bind background color to entry color
   */
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  
  BOOL isIndexColumn = [tableColumn.identifier isEqualToString:MPEntryTableIndexColumnIdentifier];
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
      NSString *modificatoinTimeKeyPath = [NSString stringWithFormat:@"%@.%@.%@",
                                           NSStringFromSelector(@selector(objectValue)),
                                           NSStringFromSelector(@selector(timeInfo)),
                                           NSStringFromSelector(@selector(modificationDate))];
      
      [view.textField bind:NSValueBinding toObject:view withKeyPath:modificatoinTimeKeyPath options:nil];
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
    else if(isIndexColumn) {
      view.textField.stringValue = @"";
    }
  }
  return view;
}

- (void)tableView:(NSTableView *)tableView didRemoveRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
  /* Rows being removed for data change should be checked here to clear selections */
  if(row == -1) {
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

#pragma mark MPTargetItemResolving
- (NSArray<KPKEntry *> *)currentTargetEntries {
  NSInteger activeRow = self.entryTable.clickedRow;
  if(activeRow > -1) {
    return @[ [self.entryArrayController arrangedObjects][activeRow] ];
  }
  return self.entryArrayController.selectedObjects;
}

- (NSArray<KPKNode *> *)currentTargetNodes {
  NSArray *entries = [self currentTargetEntries];
  if(entries.count > 0) {
    return entries;
  }
  MPDocument *document = self.windowController.document;
  return document.selectedNodes;
}

#pragma mark MPDocument Notifications
- (void)_didChangeCurrentItem:(NSNotification *)notification {
  MPDocument *document = notification.object;
  
  if(document.selectedGroups.count != 1 && !document.hasSearch) {
    /* no group selection out of search is wrong */
    self.representedObject = nil;
    return;
  }
  /*
   If a group is the current item, see if we already show that group
   also test if an element has been selected (issue #257)
   */
  if(document.selectedNodes.firstObject == document.selectedGroups.firstObject && document.selectedNodes.count > 0) {
    if(document.hasSearch) {
      /* If search was active, stop it and exit */
      [document exitSearch:self];
    }
    else if([self.entryArrayController.content count] > 0) {
      KPKEntry *entry = [self.entryArrayController.content lastObject];
      if(entry.parent == document.selectedGroups.lastObject) {
        return; // we are showing the correct object right now.
      }
    }
    self.representedObject = document.selectedGroups.count == 1 ? document.selectedGroups.firstObject : nil;
  }
  [self _updateContextBar];
}

- (void)_didBecomFirstResponder:(NSNotification *)notification {
  MPDocument *document =   self.windowController.document;
  document.selectedEntries = self.entryArrayController.selectedObjects;
  
  /*
   if(document.selectedEntry.parent == document.selectedGroup || document.hasSearch) {
   document.selectedItem = document.selectedEntry;
   }
   else {
   document.selectedEntry = nil;
   }
   */
}

- (void)_didAddItem:(NSNotification *)notification {
  MPDocument *document = notification.object;
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
  [self _showContextBar];
  NSArray *result = notification.userInfo[kMPDocumentSearchResultsKey];
  NSAssert(result != nil, @"Resutls should never be nil");
  self.filteredEntries = result;
  [self.entryArrayController unbind:NSContentArrayBinding];
  [self.entryArrayController bind:NSContentArrayBinding toObject:self withKeyPath:NSStringFromSelector(@selector(filteredEntries)) options:nil];
  [self.entryTable tableColumnWithIdentifier:MPEntryTableParentColumnIdentifier].hidden = NO;
}


- (void)_didExitSearch:(NSNotification *)notification {
  [[self.entryTable tableColumnWithIdentifier:MPEntryTableParentColumnIdentifier] setHidden:YES];
  [self _updateContextBar];
}

- (void)_didEnterSearch:(NSNotification *)notification {
  [self _showContextBar];
}

- (void)_didUnlockDatabase:(NSNotification *)notificiation {
  MPDocument *document = self.windowController.document;
  /* If the document was locked and unlocked we do not need to recheck */
  if(document.unlockCount != 1) {
    /* TODO add another method to display this!
     [self.footerInfoText setHidden:![document hasMalformedAutotypeItems]];
     [self.footerInfoText setStringValue:NSLocalizedString(@"DOCUMENT_AUTOTYPE_CORRUPTION_WARNING", "")];
     */
  }
}

- (void)_didEnterHistory:(NSNotification *)notification {
  [self _showContextBar];
}

- (void)_didExitHistory:(NSNotification *)notification {
  [self _hideContextBar];
}
#pragma mark ContextBar
- (void)_updateContextBar {
  MPDocument *document = [[self windowController] document];
  if(!document.hasSearch) {
    KPKGroup *group = self.representedObject;
    KPKNode *node = document.selectedNodes.count == 1 ? document.selectedNodes.firstObject : nil;
    BOOL showTrash = document.tree.metaData.useTrash && (group.isTrash || node.isTrashed);
    if(showTrash) {
      [self _showContextBar];
    }
    else {
      [self _hideContextBar];
    }
  }
}

- (void)_showContextBar {
  if(_isDisplayingContextBar) {
    return;
  }
  _isDisplayingContextBar = YES;
  if(!self.contextBarViewController.view.superview) {
    [self.view addSubview:[self.contextBarViewController view]];
    [self.contextBarViewController updateResponderChain];
    NSView *contextBar = self.contextBarViewController.view;
    NSView *scrollView = self.entryTable.enclosingScrollView;
    NSDictionary *views = NSDictionaryOfVariableBindings(scrollView, contextBar);
    
    /* Pin to the left */
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contextBar]|" options:0 metrics:nil views:views]];
    /* Pin height and to top of entry table */
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contextBar(==30)]-0-[scrollView]" options:0 metrics:nil views:views]];
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
    _isDisplayingContextBar = NO;
  }];
}

#pragma mark Copy/Paste Overlays
- (void)_copyToPasteboard:(NSString *)data overlayInfo:(MPOVerlayInfoType)overlayInfoType name:(NSString *)name{
  if(data) {
    [[MPPasteBoardController defaultController] copyObjects:@[ data ]];
  }
  NSImage *infoImage = nil;
  NSString *infoText = nil;
  switch (overlayInfoType) {
    case MPOverlayInfoPassword:
      infoImage = [[NSBundle mainBundle] imageForResource:@"00_PasswordTemplate"];
      infoText = NSLocalizedString(@"COPIED_PASSWORD", @"Password was copied to the pasteboard");
      break;
      
    case MPOverlayInfoURL:
      infoImage = [[NSBundle mainBundle] imageForResource:@"01_PackageNetworkTemplate"];
      infoText = NSLocalizedString(@"COPIED_URL", @"URL was copied to the pasteboard");
      break;
      
    case MPOverlayInfoUsername:
      infoImage = [[NSBundle mainBundle] imageForResource:@"09_IdentityTemplate"];
      infoText = NSLocalizedString(@"COPIED_USERNAME", @"Username was copied to the pasteboard");
      break;
      
    case MPOverlayInfoCustom:
      infoImage = [[NSBundle mainBundle] imageForResource:@"00_PasswordTemplate"];
      infoText = [NSString stringWithFormat:NSLocalizedString(@"COPIED_FIELD_%@", "Field name that was copied to the pasteboard"), name];
      break;
  }
  [[MPOverlayWindowController sharedController] displayOverlayImage:infoImage label:infoText atView:self.view];
}

#pragma mark Validation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  /* Validation is solely handled in the document */
  return [self.windowController.document validateMenuItem:menuItem];
}

#pragma mark ContextMenu
- (void)_setupEntryMenu {
  
  NSMenu *menu = [[NSMenu alloc] init];
  NSArray *items = [MPContextMenuHelper contextMenuItemsWithItems:MPContextMenuFull];
  for(NSMenuItem *item in items) {
    [menu addItem:item];
  }
  menu.delegate = _menuDelegate;
  self.entryTable.menu = menu;
}

- (void)_setupHeaderMenu {
  NSMenu *headerMenu = [[NSMenu allocWithZone:[NSMenu menuZone]] init];
  
  [headerMenu addItemWithTitle:NSLocalizedString(@"TITLE", "") action:NULL keyEquivalent:@""];
  [headerMenu addItemWithTitle:NSLocalizedString(@"USERNAME", "") action:NULL keyEquivalent:@""];
  [headerMenu addItemWithTitle:NSLocalizedString(@"PASSWORD", "") action:NULL keyEquivalent:@""];
  [headerMenu addItemWithTitle:NSLocalizedString(@"URL", "") action:NULL keyEquivalent:@""];
  [headerMenu addItemWithTitle:NSLocalizedString(@"NOTES", "") action:NULL keyEquivalent:@""];
  [headerMenu addItemWithTitle:NSLocalizedString(@"ATTACHMENTS", "") action:NULL keyEquivalent:@""];
  [headerMenu addItemWithTitle:NSLocalizedString(@"MODIFIED", "") action:NULL keyEquivalent:@""];
  
  NSArray *identifier = @[ MPEntryTableTitleColumnIdentifier,
                           MPEntryTableUserNameColumnIdentifier,
                           MPEntryTablePasswordColumnIdentifier,
                           MPEntryTableURLColumnIdentifier,
                           MPEntryTableNotesColumnIdentifier,
                           MPEntryTableAttachmentColumnIdentifier,
                           MPEntryTableModfiedColumnIdentifier ];
  
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
  NSArray *nodes = [self currentTargetNodes];
  KPKEntry *selectedEntry = nodes.count == 1 ? [nodes.firstObject asEntry] : nil;
  if(selectedEntry) {
    [self _copyToPasteboard:[selectedEntry.password kpk_finalValueForEntry:selectedEntry] overlayInfo:MPOverlayInfoPassword name:nil];
  }
}

- (void)copyUsername:(id)sender {
  NSArray *nodes = [self currentTargetNodes];
  KPKEntry *selectedEntry = nodes.count == 1 ? [nodes.firstObject asEntry] : nil;
  if(selectedEntry) {
    [self _copyToPasteboard:[selectedEntry.username kpk_finalValueForEntry:selectedEntry] overlayInfo:MPOverlayInfoUsername name:nil];
  }
}

- (void)copyCustomAttribute:(id)sender {
  NSArray *nodes = [self currentTargetNodes];
  KPKEntry *selectedEntry = nodes.count == 1 ? [nodes.firstObject asEntry] : nil;
  if(selectedEntry && [selectedEntry isKindOfClass:[KPKEntry class]]) {
    NSUInteger index = [sender tag];
    NSAssert((index >= 0)  && (index < [selectedEntry.customAttributes count]), @"Index for custom field needs to be valid");
    KPKAttribute *attribute = selectedEntry.customAttributes[index];
    [self _copyToPasteboard:attribute.evaluatedValue overlayInfo:MPOverlayInfoCustom name:attribute.key];
  }
}

- (void)copyURL:(id)sender {
  NSArray *nodes = [self currentTargetNodes];
  KPKEntry *selectedEntry = nodes.count == 1 ? [nodes.firstObject asEntry] : nil;
  if(selectedEntry) {
    [self _copyToPasteboard:[selectedEntry.url kpk_finalValueForEntry:selectedEntry] overlayInfo:MPOverlayInfoURL name:nil];
  }
}

- (void)openURL:(id)sender {
  NSArray *nodes = [self currentTargetNodes];
  KPKEntry *selectedEntry = nodes.count == 1 ? [nodes.firstObject asEntry] : nil;
  NSString *expandedURL = [selectedEntry.url kpk_finalValueForEntry:selectedEntry];
  if(expandedURL.length > 0) {
    NSURL *webURL = [NSURL URLWithString:[expandedURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *scheme = [webURL scheme];
    if(!scheme) {
      webURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [expandedURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    NSString *browserBundleID = [[NSUserDefaults standardUserDefaults] objectForKey:kMPSettingsKeyBrowserBundleId];
    BOOL openedURL = NO;
    
    if(browserBundleID) {
      openedURL = [[NSWorkspace sharedWorkspace] openURLs:@[webURL] withAppBundleIdentifier:browserBundleID options:NSWorkspaceLaunchAsync additionalEventParamDescriptor:nil launchIdentifiers:NULL];
    }
    
    if(!openedURL) {
      openedURL = [[NSWorkspace sharedWorkspace] openURL:webURL];
    }
    if(!openedURL) {
      NSLog(@"Unable to open URL %@", webURL);
    }
  }
}

- (void)delete:(id)sender {
  NSArray *entries = [self currentTargetEntries];
  MPDocument *document = self.windowController.document;
  for(KPKEntry *entry in entries) {
    [document deleteNode:entry];
  }
}


- (void)_columnDoubleClick:(id)sender {
  if(0 == [[self.entryArrayController arrangedObjects] count]) {
    return; // No data available
  }
  NSInteger columnIndex = [self.entryTable clickedColumn];
  if(columnIndex < 0 || columnIndex >= [[self.entryTable tableColumns] count]) {
    return; // No Column to use
  }
  NSTableColumn *column = [self.entryTable tableColumns][[self.entryTable clickedColumn]];
  NSString *identifier = [column identifier];
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
  // TODO: Add more actions for new columns
}

- (void)_executeTitleColumnDoubleClick {
  MPDoubleClickTitleAction action = [[NSUserDefaults standardUserDefaults] integerForKey:kMPSettingsKeyDoubleClickTitleAction];
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
  MPDoubleClickURLAction action = [[NSUserDefaults standardUserDefaults] integerForKey:kMPSettingsKeyDoubleClickURLAction];
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
