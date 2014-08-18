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
#import "MPDocument+Search.h"
#import "MPDocument+Autotype.h"
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

#import "KPKUTIs.h"
#import "KPKGroup.h"
#import "KPKEntry.h"
#import "KPKNode+IconImage.h"
#import "KPKAttribute.h"
#import "KPKTimeInfo.h"

#import "HNHTableHeaderCell.h"
#import "HNHGradientView.h"

#import "MPNotifications.h"

#import "NSString+Commands.h"

#define STATUS_BAR_ANIMATION_TIME 0.15

typedef NS_ENUM(NSUInteger,MPOVerlayInfoType) {
  MPOverlayInfoPassword,
  MPOverlayInfoUsername,
  MPOverlayInfoURL,
  MPOverlayInfoCustom,
};

NSString *const MPEntryTableUserNameColumnIdentifier = @"MPUserNameColumnIdentifier";
NSString *const MPEntryTableTitleColumnIdentifier = @"MPTitleColumnIdentifier";
NSString *const MPEntryTablePasswordColumnIdentifier = @"MPPasswordColumnIdentifier";
NSString *const MPEntryTableParentColumnIdentifier = @"MPParentColumnIdentifier";
NSString *const MPEntryTableURLColumnIdentifier = @"MPEntryTableURLColumnIdentifier";
NSString *const MPEntryTableNotesColumnIdentifier = @"MPEntryTableNotesColumnIdentifier";
NSString *const MPEntryTableAttachmentColumnIdentifier = @"MPEntryTableAttachmentColumnIdentifier";
NSString *const MPEntryTableModfiedColumnIdentifier = @"MPEntryTableModfiedColumnIdentifier";

NSString *const _MPTableImageCellView = @"ImageCell";
NSString *const _MPTableStringCellView = @"StringCell";
NSString *const _MPTAbleSecurCellView = @"PasswordCell";

@interface MPEntryViewController () {
  MPEntryContextMenuDelegate *_menuDelegate;
  BOOL _isDisplayingContextBar;
  BOOL _didUnlock;
}

@property (strong) NSArrayController *entryArrayController;
@property (strong) MPContextBarViewController *contextBarViewController;
@property (strong) NSArray *filteredEntries;

@property (weak) IBOutlet NSTableView *entryTable;

/* Constraints */
@property (strong) IBOutlet NSLayoutConstraint *tableToTopConstraint;
@property (strong) NSLayoutConstraint *contextBarTopConstraint;

@property (weak) IBOutlet HNHGradientView *bottomBar;
@property (weak) IBOutlet NSButton *addEntryButton;

@property (weak) IBOutlet NSTextField *footerInfoText;

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
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didLoadView {
  [[self view] setWantsLayer:YES];
  
  [_bottomBar setBorderType:HNHBorderTop|HNHBorderHighlight];
  [self.addEntryButton setAction:[MPActionHelper actionOfType:MPActionAddEntry]];
  
  [self.entryTable setDelegate:self];
  [self.entryTable setDoubleAction:@selector(_columnDoubleClick:)];
  [self.entryTable setTarget:self];
  [self.entryTable setFloatsGroupRows:NO];
  [self.entryTable registerForDraggedTypes:@[KPKEntryUTI]];
  /* First responder notifications */
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didBecomFirstResponder:)
                                               name:MPDidActivateViewNotification
                                             object:_entryTable];
  /* Filter bar notifications */
  [self _setupEntryMenu];
  
  NSTableColumn *parentColumn = [self.entryTable tableColumns][0];
  NSTableColumn *titleColumn = [self.entryTable tableColumns][1];
  NSTableColumn *userNameColumn = [self.entryTable tableColumns][2];
  NSTableColumn *passwordColumn = [self.entryTable tableColumns][3];
  NSTableColumn *urlColumn = [self.entryTable tableColumns][4];
  NSTableColumn *attachmentsColumn = [[NSTableColumn alloc] initWithIdentifier:MPEntryTableAttachmentColumnIdentifier];
  NSTableColumn *notesColumn = [[NSTableColumn alloc] initWithIdentifier:MPEntryTableNotesColumnIdentifier];
  NSTableColumn *modifiedColumn = [[NSTableColumn alloc] initWithIdentifier:MPEntryTableModfiedColumnIdentifier];
  [notesColumn setMinWidth:40.0];
  [attachmentsColumn setMinWidth:40.0];
  [modifiedColumn setMinWidth:40.0];
  [self.entryTable addTableColumn:notesColumn];
  [self.entryTable addTableColumn:attachmentsColumn];
  [self.entryTable addTableColumn:modifiedColumn];
  
  [parentColumn setIdentifier:MPEntryTableParentColumnIdentifier];
  [titleColumn setIdentifier:MPEntryTableTitleColumnIdentifier];
  [userNameColumn setIdentifier:MPEntryTableUserNameColumnIdentifier];
  [passwordColumn setIdentifier:MPEntryTablePasswordColumnIdentifier];
  [urlColumn setIdentifier:MPEntryTableURLColumnIdentifier];
  
  [self.entryTable setAutosaveName:@"EntryTable"];
  [self.entryTable setAutosaveTableColumns:YES];
  
  NSString *parentNameKeyPath = [[NSString alloc] initWithFormat:@"%@.%@", NSStringFromSelector(@selector(parent)), NSStringFromSelector(@selector(name))];
  NSString *timeInfoModificationTimeKeyPath = [[NSString alloc] initWithFormat:@"%@.%@", NSStringFromSelector(@selector(timeInfo)), NSStringFromSelector(@selector(lastModificationTime))];
	NSSortDescriptor *titleColumSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(title))ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
  NSSortDescriptor *userNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(username)) ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
  NSSortDescriptor *urlSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(url)) ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
  NSSortDescriptor *groupnameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:parentNameKeyPath ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
  NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:timeInfoModificationTimeKeyPath ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
  
  [titleColumn setSortDescriptorPrototype:titleColumSortDescriptor];
  [userNameColumn setSortDescriptorPrototype:userNameSortDescriptor];
  [urlColumn setSortDescriptorPrototype:urlSortDescriptor];
  [parentColumn setSortDescriptorPrototype:groupnameSortDescriptor];
  [modifiedColumn setSortDescriptorPrototype:dateSortDescriptor];
  
  [[parentColumn headerCell] setStringValue:NSLocalizedString(@"GROUP", "")];
  [[titleColumn headerCell] setStringValue:NSLocalizedString(@"TITLE", "")];
  [[userNameColumn headerCell] setStringValue:NSLocalizedString(@"USERNAME", "")];
  [[passwordColumn headerCell] setStringValue:NSLocalizedString(@"PASSWORD", "")];
  [[urlColumn headerCell] setStringValue:NSLocalizedString(@"URL", "")];
  [[notesColumn headerCell] setStringValue:NSLocalizedString(@"NOTES", "")];
  [[attachmentsColumn headerCell] setStringValue:NSLocalizedString(@"ATTACHMENTS", "")];
  [[modifiedColumn headerCell] setStringValue:NSLocalizedString(@"MODIFIED", "")];
  
  [self.entryTable bind:NSContentBinding toObject:self.entryArrayController withKeyPath:NSStringFromSelector(@selector(arrangedObjects)) options:nil];
  [self.entryTable bind:NSSortDescriptorsBinding toObject:self.entryArrayController withKeyPath:NSStringFromSelector(@selector(sortDescriptors)) options:nil];
  [self.entryTable setDataSource:_dataSource];
  
  // bind NSArrayController sorting so that sort order gets auto-saved
  // see: http://simx.me/technonova/software_development/sort_descriptors_nstableview_bindings_a.html
  [self.entryArrayController bind:NSSortDescriptorsBinding
                         toObject:[NSUserDefaultsController sharedUserDefaultsController]
                      withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyEntryTableSortDescriptors]
                          options:@{ NSValueTransformerNameBindingOption: NSUnarchiveFromDataTransformerName }];
  
  [self _setupHeaderMenu];
  [parentColumn setHidden:YES];
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
  [self.contextBarViewController registerNotificationsForDocument:document];
}

#pragma mark NSTableViewDelgate

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
  /*
   bind bakground color to entry color
   */
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  KPKEntry *entry = [self.entryArrayController arrangedObjects][row];
  BOOL isTitleColumn = [[tableColumn identifier] isEqualToString:MPEntryTableTitleColumnIdentifier];
  BOOL isGroupColumn = [[tableColumn identifier] isEqualToString:MPEntryTableParentColumnIdentifier];
  BOOL isPasswordColum = [[tableColumn identifier] isEqualToString:MPEntryTablePasswordColumnIdentifier];
  BOOL isUsernameColumn = [[tableColumn identifier] isEqualToString:MPEntryTableUserNameColumnIdentifier];
  BOOL isURLColumn = [[tableColumn identifier] isEqualToString:MPEntryTableURLColumnIdentifier];
  BOOL isAttachmentColumn = [[tableColumn identifier] isEqualToString:MPEntryTableAttachmentColumnIdentifier];
  BOOL isNotesColumn = [[tableColumn identifier] isEqualToString:MPEntryTableNotesColumnIdentifier];
  BOOL isModifedColumn = [[tableColumn identifier] isEqualToString:MPEntryTableModfiedColumnIdentifier];
  
  NSTableCellView *view = nil;
  if(isTitleColumn || isGroupColumn) {
    view = [tableView makeViewWithIdentifier:_MPTableImageCellView owner:self];
    if( isTitleColumn ) {
      [[view textField] bind:NSValueBinding toObject:entry withKeyPath:NSStringFromSelector(@selector(title)) options:nil];
      [[view imageView] bind:NSValueBinding toObject:entry withKeyPath:NSStringFromSelector(@selector(iconImage)) options:nil];
    }
    else {
      NSAssert(entry.parent != nil, @"Entry needs to have a parent");
      [[view textField] bind:NSValueBinding toObject:entry.parent withKeyPath:NSStringFromSelector(@selector(name)) options:nil];
      [[view imageView] bind:NSValueBinding toObject:entry.parent withKeyPath:NSStringFromSelector(@selector(iconImage)) options:nil];
    }
  }
  else if(isPasswordColum) {
    view = [tableView makeViewWithIdentifier:_MPTAbleSecurCellView owner:self];
    NSDictionary *options = @{ NSValueTransformerBindingOption : [NSValueTransformer valueTransformerForName:MPStringLengthValueTransformerName] };
    [[view textField] bind:NSValueBinding toObject:entry withKeyPath:NSStringFromSelector(@selector(password)) options:options];
  }
  else  {
    view = [tableView makeViewWithIdentifier:_MPTableStringCellView owner:self];
    NSTextField *textField = [view textField];
    if(!isModifedColumn) {
      /* clean up old formatter that might be left */
      [textField setFormatter:nil];
    }
    if(isModifedColumn) {
      if(![[view textField] formatter]) {
        /* Just use one formatter instance since it's expensive to create */
        static NSDateFormatter *formatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
          formatter = [[NSDateFormatter alloc] init];
          [formatter setDateStyle:NSDateFormatterMediumStyle];
          [formatter setTimeStyle:NSDateFormatterMediumStyle];
        });
        [textField setFormatter:formatter];
      }
      [textField bind:NSValueBinding toObject:entry.timeInfo withKeyPath:NSStringFromSelector(@selector(lastModificationTime)) options:nil];
      return view;
    }
    else if(isURLColumn) {
      [textField bind:NSValueBinding toObject:entry withKeyPath:NSStringFromSelector(@selector(url)) options:nil];
    }
    else if(isUsernameColumn) {
      [textField bind:NSValueBinding toObject:entry withKeyPath:NSStringFromSelector(@selector(username)) options:nil];
    }
    else if(isNotesColumn) {
      NSDictionary *options = @{ NSValueTransformerNameBindingOption : MPStripLineBreaksTransformerName };
      [textField bind:NSValueBinding toObject:entry withKeyPath:NSStringFromSelector(@selector(notes)) options:options];
    }
    else if(isAttachmentColumn) {
      [textField bind:NSValueBinding toObject:entry withKeyPath:@"binaries.@count" options:nil];
    }
  }
  return view;
}

- (void)tableView:(NSTableView *)tableView didRemoveRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
  /* Rows being removed for data change should be chekced here to clear selections */
  if(row == -1) {
    [self tableViewSelectionDidChange:nil];
  }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  MPDocument *document = [[self windowController] document];
  if([self.entryTable selectedRow] < 0 || [[_entryTable selectedRowIndexes] count] > 1) {
    document.selectedEntry = nil;
  }
  else {
    document.selectedEntry = [self.entryArrayController arrangedObjects][[self.entryTable selectedRow]];
  }
}

#pragma mark MPDocument Notifications
- (void)_didChangeCurrentItem:(NSNotification *)notification {
  MPDocument *document = [notification object];
  
  if(!document.selectedGroup) {
    /* TODO: handle deleted item */
    return;
  }
  /*
   If a group is the current item, see if we already show that group
   */
  if(document.selectedItem == document.selectedGroup) {
    if(document.hasSearch) {
      /* If search was active, stop it and exit */
      [document exitSearch:self];
    }
    else if([[self.entryArrayController content] count] > 0) {
      KPKEntry *entry = [[self.entryArrayController content] lastObject];
      if(entry.parent == document.selectedGroup) {
        return; // we are showing the correct object right now.
      }
    }
    [self.entryArrayController bind:NSContentArrayBinding toObject:document.selectedGroup withKeyPath:NSStringFromSelector(@selector(entries)) options:nil];
  }
  [self _updateContextBar];
}

- (void)_didBecomFirstResponder:(NSNotification *)notification {
  MPDocument *document = [[self windowController] document];
  if(document.selectedEntry.parent == document.selectedGroup || document.hasSearch) {
    document.selectedItem = document.selectedEntry;
  }
  else {
    document.selectedEntry = nil;
  }
}

- (void)_didAddItem:(NSNotification *)notification {
  MPDocument *document = [[self windowController] document];
  KPKEntry *entry = document.selectedGroup.entries.lastObject;
  NSUInteger row = [self.entryArrayController.arrangedObjects indexOfObject:entry];
  [self.entryTable scrollRowToVisible:row];
  [self.entryTable selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void)_didUpdateSearchResults:(NSNotification *)notification {
  [self _showContextBar];
  NSArray *result = [notification userInfo][kMPDocumentSearchResultsKey];
  NSAssert(result != nil, @"Resutls should never be nil");
  self.filteredEntries = result;
  [self.entryArrayController unbind:NSContentArrayBinding];
  [self.entryArrayController setContent:self.filteredEntries];
  [[self.entryTable tableColumnWithIdentifier:MPEntryTableParentColumnIdentifier] setHidden:NO];
}


- (void)_didExitSearch:(NSNotification *)notification {
  [[self.entryTable tableColumnWithIdentifier:MPEntryTableParentColumnIdentifier] setHidden:YES];
  MPDocument *document = [[self windowController] document];
  document.selectedItem = document.selectedGroup;
  [self.entryArrayController bind:NSContentArrayBinding toObject:document.selectedGroup withKeyPath:NSStringFromSelector(@selector(entries)) options:nil];
  [self _updateContextBar];
}

- (void)_didEnterSearch:(NSNotification *)notification {
  [self _showContextBar];
}

- (void)_didUnlockDatabase:(NSNotification *)notificiation {
  MPDocument *document = [[self windowController] document];
  /* If the document was locked and unlocked we do not need to recheck */
  if(document.unlockCount != 1) {
    [self.footerInfoText setHidden:![document hasMalformedAutotypeItems]];
    [self.footerInfoText setStringValue:NSLocalizedString(@"DOCUMENT_AUTOTYPE_CORRUPTION_WARNING", "")];
  }
}

#pragma mark ContextBar
- (void)_updateContextBar {
  MPDocument *document = [[self windowController] document];
  if(!document.hasSearch) {
    BOOL showTrash = document.useTrash && (document.selectedGroup == document.trash || [document isItemTrashed:document.selectedItem]);
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
  if(![[self.contextBarViewController view] superview]) {
    [[self view] addSubview:[self.contextBarViewController view]];
    [self.contextBarViewController updateResponderChain];
    NSView *contextBar = [self.contextBarViewController view];
    NSView *scrollView = [_entryTable enclosingScrollView];
    NSDictionary *views = NSDictionaryOfVariableBindings(scrollView, contextBar);
    
    /* Pin to the left */
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contextBar]|" options:0 metrics:nil views:views]];
    /* Pin height and to top of entry table */
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contextBar(==30)]-0-[scrollView]" options:0 metrics:nil views:views]];
    /* Create the top constraint for the filter bar where we can change the contanst instaed of removing/adding constraints all the time */
    self.contextBarTopConstraint = [NSLayoutConstraint constraintWithItem:contextBar
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:[self view]
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1
                                                                 constant:-31];
  }
  /* Add the view for the first time */
  [[self view] removeConstraint:self.tableToTopConstraint];
  [[self view] addConstraint:self.contextBarTopConstraint];
  [[self view] layout];
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
  [[self view] addConstraint:self.tableToTopConstraint];
  
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
      infoText = [NSString stringWithFormat:NSLocalizedString(@"COPIED_FIELD_%@", "Field nam that was copied to the pasteboard"), name];
      break;
  }
  [[MPOverlayWindowController sharedController] displayOverlayImage:infoImage label:infoText atView:self.view];
}

#pragma mark Validation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  MPDocument *document = [[self windowController] document];
  if(![document validateMenuItem:menuItem]) {
    return NO;
  }
  
  KPKEntry *targetEntry = [self _clickedOrSelectedEntry];
  MPActionType actionType = [MPActionHelper typeForAction:[menuItem action]];
  
  switch (actionType) {
    case MPActionCopyUsername:
      return  [targetEntry.username length] > 0;
      
    case MPActionCopyPassword:
      return  [targetEntry.password length] > 0;
      
    case MPActionCopyURL:
    case MPActionOpenURL:
      return [targetEntry.url length] > 0;
      
    default:
      return YES;
  }
}

#pragma mark ContextMenu
- (void)_setupEntryMenu {
  
  NSMenu *menu = [[NSMenu alloc] init];
  NSArray *items = [MPContextMenuHelper contextMenuItemsWithItems:MPContextMenuFull];
  for(NSMenuItem *item in items) {
    [menu addItem:item];
  }
  [menu setDelegate:_menuDelegate];
  [self.entryTable setMenu:menu];
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
  for(NSMenuItem *item in [headerMenu itemArray]) {
    NSUInteger index = [headerMenu indexOfItem:item];
    NSTableColumn *column= [self.entryTable tableColumnWithIdentifier:identifier[index]];
    [item bind:NSValueBinding toObject:column withKeyPath:NSHiddenBinding options:options];
  }
  
  [[self.entryTable headerView] setMenu:headerMenu];
}


#pragma mark Action Helper

- (KPKEntry *)_clickedOrSelectedEntry {
  NSInteger activeRow = [self.entryTable clickedRow];
  /* Fallback to selection e.g. for toolbar actions */
  if(activeRow < 0 ) {
    activeRow = [self.entryTable selectedRow];
  }
  if(activeRow >= 0 && activeRow <= [[self.entryArrayController arrangedObjects] count]) {
    return [self.entryArrayController arrangedObjects][activeRow];
  }
  return nil;
}

#pragma mark Actions
- (void)copyPassword:(id)sender {
  KPKEntry *selectedEntry = [self _clickedOrSelectedEntry];
  if(selectedEntry) {
    [self _copyToPasteboard:[selectedEntry.password finalValueForEntry:selectedEntry] overlayInfo:MPOverlayInfoPassword name:nil];
  }
}

- (void)copyUsername:(id)sender {
  KPKEntry *selectedEntry = [self _clickedOrSelectedEntry];
  if(selectedEntry) {
    [self _copyToPasteboard:[selectedEntry.username finalValueForEntry:selectedEntry] overlayInfo:MPOverlayInfoUsername name:nil];
  }
}

- (void)copyCustomAttribute:(id)sender {
  KPKEntry *selectedEntry = [self _clickedOrSelectedEntry];
  if(selectedEntry && [selectedEntry isKindOfClass:[KPKEntry class]]) {
    NSUInteger index = [sender tag];
    NSAssert((index >= 0)  && (index < [selectedEntry.customAttributes count]), @"Index for custom field needs to be valid");
    KPKAttribute *attribute = selectedEntry.customAttributes[index];
    [self _copyToPasteboard:attribute.evaluatedValue overlayInfo:MPOverlayInfoCustom name:attribute.key];
  }
}

- (void)copyURL:(id)sender {
  KPKEntry *selectedEntry = [self _clickedOrSelectedEntry];
  if(selectedEntry) {
    [self _copyToPasteboard:[selectedEntry.url finalValueForEntry:selectedEntry] overlayInfo:MPOverlayInfoURL name:nil];
  }
}

- (void)openURL:(id)sender {
  KPKEntry *selectedEntry = [self _clickedOrSelectedEntry];
  if(selectedEntry && [selectedEntry.url length] > 0) {
    NSURL *webURL = [NSURL URLWithString:[selectedEntry.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *scheme = [webURL scheme];
    if(!scheme) {
      webURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [selectedEntry.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    NSString *browserBundleID = [[NSUserDefaults standardUserDefaults] objectForKey:kMPSettingsKeyBrowserBundleId];
    BOOL launched = NO;
    
    if (browserBundleID) {
      launched = [[NSWorkspace sharedWorkspace] openURLs:@[webURL] withAppBundleIdentifier:browserBundleID options:NSWorkspaceLaunchAsync additionalEventParamDescriptor:nil launchIdentifiers:NULL];
    }
    
    if (!launched) {
      [[NSWorkspace sharedWorkspace] openURL:webURL];
    }
  }
}

- (IBAction)enterHistoryBrowser:(id)sender {
  
}

- (void)delete:(id)sender {
  KPKEntry *entry =[self _clickedOrSelectedEntry];
  if(!entry) {
    return;
  }
  MPDocument *document = [[self windowController] document];
  [document deleteEntry:entry];
}


- (void)_columnDoubleClick:(id)sender {
  if(0 == [[self.entryArrayController arrangedObjects] count]) {
    return; // No data available
  }
  NSInteger columnIndex = [self.entryTable clickedColumn];
  if(columnIndex < 0 || columnIndex >= [[self.entryTable tableColumns] count]) {
    return; // No Colum to use
  }
  NSTableColumn *column = [self.entryTable tableColumns][[self.entryTable clickedColumn]];
  NSString *identifier = [column identifier];
  if([identifier isEqualToString:MPEntryTableTitleColumnIdentifier]) {
    MPDoubleClickTitleAction action = [[NSUserDefaults standardUserDefaults] integerForKey:kMPSettingsKeyDoubleClickTitleAction];
    if (action == MPDoubleClickTitleActionInspect) {
      [[self windowController] showInspector:nil];
    }
    else if (action == MPDoubleClickTitleActionIgnore) {
      
    }
    else {
      NSLog(@"Unknown double click action");
    }
    
  }
  else if([identifier isEqualToString:MPEntryTablePasswordColumnIdentifier]) {
    [self copyPassword:nil];
  }
  else if([identifier isEqualToString:MPEntryTableUserNameColumnIdentifier]) {
    [self copyUsername:nil];
  }
  else if([identifier isEqualToString:MPEntryTableURLColumnIdentifier]) {
    MPDoubleClickURLAction action = [[NSUserDefaults standardUserDefaults] integerForKey:kMPSettingsKeyDoubleClickURLAction];
    if(action == MPDoubleClickURLActionOpen) {
      [self openURL:nil];
    }
    else if (action == MPDoubleClickURLActionCopy) {
      [self copyURL:nil];
    }
    else {
      NSLog(@"Unknown double click URL action");
    }
  }
  // TODO: Add more actions for new columns
}

@end
