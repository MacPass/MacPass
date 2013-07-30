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
#import "MPIconHelper.h"
#import "MPDocumentWindowController.h"
#import "MPPasteBoardController.h"
#import "MPOverlayWindowController.h"

#import "MPContextMenuHelper.h"
#import "MPActionHelper.h"
#import "MPSettingsHelper.h"
#import "MPConstants.h"
#import "MPEntryTableDataSource.h"
#import "MPStringLengthValueTransformer.h"
#import "MPEntryMenuDelegate.h"

#import "HNHTableHeaderCell.h"
#import "HNHGradientView.h"

#import "Kdb4Node.h"
#import "KdbGroup+MPTreeTools.h"
#import "KdbGroup+Undo.h"
#import "KdbEntry+Undo.h"

#import "MPNotifications.h"

#define STATUS_BAR_ANIMATION_TIME 0.15

typedef NS_OPTIONS(NSUInteger, MPFilterModeType) {
  MPFilterNone      = 0,
  MPFilterUrls      = (1<<0),
  MPFilterUsernames = (1<<1),
  MPFilterTitles    = (1<<2),
};

typedef NS_ENUM(NSUInteger,MPOVerlayInfoType) {
  MPOverlayInfoPassword,
  MPOverlayInfoUsername,
  MPOverlayInfoURL,
  MPOverlayInfoCustom
};

NSString *const MPEntryTableUserNameColumnIdentifier = @"MPUserNameColumnIdentifier";
NSString *const MPEntryTableTitleColumnIdentifier = @"MPTitleColumnIdentifier";
NSString *const MPEntryTablePasswordColumnIdentifier = @"MPPasswordColumnIdentifier";
NSString *const MPEntryTableParentColumnIdentifier = @"MPParentColumnIdentifier";
NSString *const MPEntryTableURLColumnIdentifier = @"MPEntryTableURLColumnIdentifier";

NSString *const _MPTableImageCellView = @"ImageCell";
NSString *const _MPTableStringCellView = @"StringCell";
NSString *const _MPTAbleSecurCellView = @"PasswordCell";

NSString *const _toggleFilterURLButton = @"SearchURL";
NSString *const _toggleFilterTitleButton = @"SearchTitle";
NSString *const _toggleFilterUsernameButton = @"SearchUsername";

@interface MPEntryViewController () {
  MPEntryMenuDelegate *_menuDelegate;
}

@property (strong) NSArrayController *entryArrayController;
@property (strong) NSArray *filteredEntries;
@property (strong) IBOutlet NSView *filterBar;
@property (strong) IBOutlet HNHGradientView *trashBar;
@property (weak) IBOutlet NSTableView *entryTable;
@property (strong) IBOutlet NSLayoutConstraint *tableToTopConstraint;
@property (strong) NSLayoutConstraint *filterbarTopConstraint;
@property (weak) IBOutlet NSButton *filterDoneButton;

@property (weak) IBOutlet NSButton *filterTitleButton;
@property (weak) IBOutlet NSButton *filterUsernameButton;
@property (weak) IBOutlet NSButton *filterURLButton;
@property (weak) IBOutlet NSTextField *filterLabelTextField;
@property (weak) IBOutlet NSSearchField *filterSearchField;
@property (weak) IBOutlet HNHGradientView *bottomBar;
@property (weak) IBOutlet NSButton *addEntryButton;
@property (weak) IBOutlet NSTextField *entryCountTextField;


@property (weak) KdbEntry *selectedEntry;

@property (nonatomic, strong) MPEntryTableDataSource *dataSource;

@property (assign, nonatomic) MPFilterModeType filterMode;
@property (strong, nonatomic) NSDictionary *filterButtonToMode;

@end

@implementation MPEntryViewController


- (id)init {
  return [[MPEntryViewController alloc] initWithNibName:@"EntryView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self) {
    _filterMode = MPFilterTitles;
    _filterButtonToMode = @{ _toggleFilterUsernameButton : @(MPFilterUsernames),
                             _toggleFilterTitleButton : @(MPFilterTitles),
                             _toggleFilterURLButton : @(MPFilterUrls)
                             };
    _entryArrayController = [[NSArrayController alloc] init];
    _dataSource = [[MPEntryTableDataSource alloc] init];
    _dataSource.viewController = self;
    _menuDelegate = [[MPEntryMenuDelegate alloc] init];
    _menuDelegate.viewController = self;
    
    _selectedEntry = nil;
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
}

- (void)didLoadView {
  [self.view setWantsLayer:YES];
  [self _hideFilterBarAnimated];
  
  [_bottomBar setBorderType:HNHBorderTop];
  [self.addEntryButton setAction:[MPActionHelper actionOfType:MPActionAddEntry]];
  
  [self.entryTable setDelegate:self];
  [self.entryTable setDoubleAction:@selector(_columnDoubleClick:)];
  [self.entryTable setTarget:self];
  [self.entryTable setFloatsGroupRows:NO];
  //[self.entryTable registerForDraggedTypes:@[MPPasteBoardType]];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didBecomFirstResponder:)
                                               name:MPDidActivateViewNotification
                                             object:_entryTable];
  
  [self _setupEntryMenu];
  
  NSTableColumn *parentColumn = [self.entryTable tableColumns][0];
  NSTableColumn *titleColumn = [self.entryTable tableColumns][1];
  NSTableColumn *userNameColumn = [self.entryTable tableColumns][2];
  NSTableColumn *passwordColumn = [self.entryTable tableColumns][3];
  NSTableColumn *urlColumn = [self.entryTable tableColumns][4];
  
  
  [parentColumn setIdentifier:MPEntryTableParentColumnIdentifier];
  [titleColumn setIdentifier:MPEntryTableTitleColumnIdentifier];
  [userNameColumn setIdentifier:MPEntryTableUserNameColumnIdentifier];
  [passwordColumn setIdentifier:MPEntryTablePasswordColumnIdentifier];
  [urlColumn setIdentifier:MPEntryTableURLColumnIdentifier];
  
  [self.entryTable setAutosaveName:@"EntryTable"];
  [self.entryTable setAutosaveTableColumns:YES];
  
	NSSortDescriptor *titleColumSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(compare:)];
  NSSortDescriptor *userNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES selector:@selector(compare:)];
  NSSortDescriptor *urlSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"url" ascending:YES selector:@selector(compare:)];
  
  [titleColumn setSortDescriptorPrototype:titleColumSortDescriptor];
  [userNameColumn setSortDescriptorPrototype:userNameSortDescriptor];
  [urlColumn setSortDescriptorPrototype:urlSortDescriptor];
  
  [[parentColumn headerCell] setStringValue:@"Group"];
  [[titleColumn headerCell] setStringValue:@"Title"];
  [[userNameColumn headerCell] setStringValue:@"Username"];
  [[passwordColumn headerCell] setStringValue:@"Password"];
  [[urlColumn headerCell] setStringValue:@"URL"];
  
  [self.entryTable bind:NSContentBinding toObject:self.entryArrayController withKeyPath:@"arrangedObjects" options:nil];
  [self.entryTable bind:NSSortDescriptorsBinding toObject:self.entryArrayController withKeyPath:@"sortDescriptors" options:nil];
  [self.entryTable setDataSource:_dataSource];
  
  [parentColumn setHidden:YES];
  
}

- (void)setupNotifications:(MPDocumentWindowController *)windowController {
  MPDocument *document = [windowController document];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didChangeCurrentItem:)
                                               name:MPCurrentItemChangedNotification
                                             object:document];
}

#pragma mark NSTableViewDelgate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  KdbEntry *entry = [self.entryArrayController arrangedObjects][row];
  
  const BOOL isTitleColumn = [[tableColumn identifier] isEqualToString:MPEntryTableTitleColumnIdentifier];
  const BOOL isGroupColumn = [[tableColumn identifier] isEqualToString:MPEntryTableParentColumnIdentifier];
  const BOOL isPasswordColum = [[tableColumn identifier] isEqualToString:MPEntryTablePasswordColumnIdentifier];
  const BOOL isUsernameColumn = [[tableColumn identifier] isEqualToString:MPEntryTableUserNameColumnIdentifier];
  const BOOL isURLColumn = [[tableColumn identifier] isEqualToString:MPEntryTableURLColumnIdentifier];
  
  NSTableCellView *view = nil;
  if(isTitleColumn || isGroupColumn) {
    view = [tableView makeViewWithIdentifier:_MPTableImageCellView owner:self];
    if( isTitleColumn ) {
      [[view textField] bind:NSValueBinding toObject:entry withKeyPath:MPEntryTitleUndoableKey options:nil];
      [[view imageView] setImage:[MPIconHelper icon:(MPIconType)entry.image]];
    }
    else {
      assert(entry.parent);
      [[view textField] bind:NSValueBinding toObject:entry.parent withKeyPath:MPGroupNameUndoableKey options:nil];
      [[view imageView] setImage:[MPIconHelper icon:(MPIconType)entry.parent.image]];
    }
  }
  else if( isPasswordColum ) {
    view = [tableView makeViewWithIdentifier:_MPTAbleSecurCellView owner:self];
    NSDictionary *options = @{ NSValueTransformerBindingOption : [NSValueTransformer valueTransformerForName:MPStringLengthValueTransformerName] };
    [[view textField] bind:NSValueBinding toObject:entry withKeyPath:MPEntryPasswordUndoableKey options:options];
  }
  else if( isUsernameColumn || isURLColumn ) {
    view = [tableView makeViewWithIdentifier:_MPTableStringCellView owner:self];
    if(isURLColumn) {
      [[view textField] bind:NSValueBinding toObject:entry withKeyPath:MPEntryUrlUndoableKey options:nil];
      //[[view textField] setStringValue:entry.url];
    }
    else {
      [[view textField] bind:NSValueBinding toObject:entry withKeyPath:MPEntryUsernameUndoableKey options:nil];
      //[[view textField] setStringValue:entry.username];
    }
  }
  
  return view;
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

#pragma mark Notifications
- (void)_didChangeCurrentItem:(NSNotification *)notification {
  MPDocument *document = [notification object];
  
  if(!document.selectedGroup) {
    [self.entryArrayController unbind:NSContentArrayBinding];
    [self.entryArrayController setContent:nil];
    return;
  }
  /*
   If a grup is the current item, see if we already show that group
   */
  if(document.selectedItem == document.selectedGroup) {
    /*
     If we reselct the group, or just another group
     we clear the filter and bind to the new selected group
     */
    if([self _showsFilterBar] && ![document.selectedItem isKindOfClass:[KdbEntry class]]) {
      [self clearFilter:nil];
      [self.entryArrayController bind:NSContentArrayBinding toObject:document.selectedGroup withKeyPath:@"entries" options:nil];
      return;
    }
    if([[self.entryArrayController content] count] > 0) {
      KdbEntry *entry = [[self.entryArrayController content] lastObject];
      if(entry.parent == document.selectedGroup) {
        return; // we are showing the correct object right now.
      }
    }
    [self.entryArrayController bind:NSContentArrayBinding toObject:document.selectedGroup withKeyPath:@"entries" options:nil];
  }
}

- (void)_didBecomFirstResponder:(NSNotification *)notification {
  MPDocument *document = [[self windowController] document];
  if(document.selectedEntry.parent == document.selectedGroup
     || [self _showsFilterBar]) {
    document.selectedItem = document.selectedEntry;
  }
  else {
    document.selectedEntry = nil;
  }
}


#pragma mark Filtering

- (void)showFilter:(id)sender {
  [self _showFilterBarAnimated];
}

- (BOOL)hasFilter {
  return ([self.filter length] > 0);
}

- (void)setFilter:(NSString *)filter {
  if(_filter != filter) {
    _filter = filter;
    [self updateFilter];
  }
}

- (void)clearFilter:(id)sender {
  self.filter = nil;
  [self.filterSearchField setStringValue:@""];
  [[self.entryTable tableColumnWithIdentifier:MPEntryTableParentColumnIdentifier] setHidden:YES];
  [self _hideFilterBarAnimated];
  MPDocument *document = [[self windowController] document];
  document.selectedGroup = document.selectedGroup;
}

- (void)updateFilter {
  //[self _showFilterBarAnimated];
  if(![self hasFilter]) {
    return;
  }
  
  dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(backgroundQueue, ^{
    MPDocument *document = [[self windowController] document];
    if([self hasFilter]) {
      NSMutableArray *prediactes = [NSMutableArray arrayWithCapacity:3];
      if( [self _shouldFilterTitles] ) {
        [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.title CONTAINS[cd] %@", self.filter]];
      }
      if( [self _shouldFilterUsernames] ) {
        [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.username CONTAINS[cd] %@", self.filter]];
      }
      if( [self _shouldFilterURLs] ) {
        [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.url CONTAINS[cd] %@", self.filter]];
      }
      NSPredicate *fullFilter = [NSCompoundPredicate orPredicateWithSubpredicates:prediactes];
      self.filteredEntries = [[document.root childEntries] filteredArrayUsingPredicate:fullFilter];
    }
    
    else {
      self.filteredEntries = [document.root childEntries];
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
      document.selectedEntry = nil;
      [self.entryArrayController unbind:NSContentArrayBinding];
      [self.entryArrayController setContent:self.filteredEntries];
      [[self.entryTable tableColumnWithIdentifier:MPEntryTableParentColumnIdentifier] setHidden:NO];
    });
  });
  
}

- (void)updateFilterText:(id)sender {
  self.filter = [self.filterSearchField stringValue];
}

- (void)setupFilterBar {
  if(!self.filterBar) {
    [[NSBundle mainBundle] loadNibNamed:@"FilterBar" owner:self topLevelObjects:nil];
    [self.filterURLButton setIdentifier:_toggleFilterURLButton];
    [self.filterUsernameButton setIdentifier:_toggleFilterUsernameButton];
    [self.filterTitleButton setIdentifier:_toggleFilterTitleButton];
    [[self.filterLabelTextField cell] setBackgroundStyle:NSBackgroundStyleRaised];
    [self.filterDoneButton setAction:@selector(clearFilter:)];
    [self.filterDoneButton setTarget:nil];
    
    [self.filterSearchField setAction:@selector(updateFilterText:)];
    [[self.filterSearchField cell] setSendsSearchStringImmediately:NO];
  }
}

- (BOOL)_showsFilterBar {
  return ( nil != [self.filterBar superview]);
}

#pragma mark UI Feedback

- (void)_showFilterBarAnimated {
  
  if(!self.filterBar) {
    [self setupFilterBar];
  }
  /*
   Make sure the buttons are set correctyl every time
   */
  [self.filterTitleButton setState:[self _shouldFilterTitles] ? NSOnState : NSOffState];
  [self.filterURLButton setState:[self _shouldFilterURLs] ? NSOnState : NSOffState ];
  [self.filterUsernameButton setState:[self _shouldFilterUsernames] ? NSOnState : NSOffState];
  
  if([self _showsFilterBar]) {
    return; // nothing to to
  }
  
  NSView *scrollView = [_entryTable enclosingScrollView];
  NSDictionary *views = NSDictionaryOfVariableBindings(scrollView, _filterBar);
  
  [[self view] addSubview:self.filterBar];
  
  [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_filterBar]|" options:0 metrics:nil views:views]];
  [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_filterBar(==30)]-0-[scrollView]" options:0 metrics:nil views:views]];
  [[self view] layoutSubtreeIfNeeded];
  
  [[self view] removeConstraint:self.tableToTopConstraint];
  self.filterbarTopConstraint = [NSLayoutConstraint constraintWithItem:self.filterBar
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:[self view]
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:0];
  [[self view] addConstraint:self.filterbarTopConstraint];
  
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext* context) {
    context.duration = STATUS_BAR_ANIMATION_TIME;
    context.allowsImplicitAnimation = YES;
    [self.view layoutSubtreeIfNeeded];
  } completionHandler:^{
    [[[self windowController] window] makeFirstResponder:self.filterSearchField];
  }];
  
}

- (void)_hideFilterBarAnimated {
  
  if(![self _showsFilterBar]) {
    return; // nothing to do;
  }
  
  [[self view] removeConstraint:self.filterbarTopConstraint];
  [self.view addConstraint:self.tableToTopConstraint];
  
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext* context) {
    context.duration = STATUS_BAR_ANIMATION_TIME;
    context.allowsImplicitAnimation = YES;
    [self.view layoutSubtreeIfNeeded];
  } completionHandler:^{
    [self.filterBar removeFromSuperview];
  }] ;
}


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

- (void)_showTrashBar {
  if([self hasFilter]) {
    [self clearFilter:nil];
  }
  if(!self.trashBar) {
    [self _setupTrashBar];
  }
  NSView *scrollView = [_entryTable enclosingScrollView];
  NSDictionary *views = NSDictionaryOfVariableBindings(scrollView, _trashBar);
  [[self view] layout];
  [[self view] removeConstraint:self.tableToTopConstraint];
  [[self view] addSubview:self.trashBar];
  [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_trashBar]|" options:0 metrics:nil views:views]];
  [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_trashBar(==30)]-0-[scrollView]" options:0 metrics:nil views:views]];
  
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext* context) {
    context.duration = STATUS_BAR_ANIMATION_TIME;
    context.allowsImplicitAnimation = YES;
    [[self view] layoutSubtreeIfNeeded];
  } completionHandler:nil] ;
  
  
  //[[self view] layoutSubtreeIfNeeded];
  
}

- (void)_hideTrashBar {
  if(![self.trashBar superview]) {
    return; // Trahsbar is not visible
  }
  
  [self.trashBar removeFromSuperview];
  [[self view] addConstraint:self.tableToTopConstraint];
  [[self view] layoutSubtreeIfNeeded];
}

- (void)_setupTrashBar {
  /* Load the bundle */
  [[NSBundle mainBundle] loadNibNamed:@"TrashBar" owner:self topLevelObjects:nil];
  NSArray *activeColors = @[
                            [NSColor colorWithCalibratedWhite:0.2 alpha:1],
                            [NSColor colorWithCalibratedWhite:0.4 alpha:1]
                            ];
  NSArray *inactiveColors = @[ [NSColor colorWithCalibratedWhite:0.3 alpha:1],
                               [NSColor colorWithCalibratedWhite:0.6 alpha:1]
                               ];
  self.trashBar.activeGradient = [[NSGradient alloc] initWithColors:activeColors];
  self.trashBar.inactiveGradient = [[NSGradient alloc] initWithColors:inactiveColors];
}

#pragma mark EntryMenu

- (void)_setupEntryMenu {
  
  NSMenu *menu = [[NSMenu alloc] init];
  NSArray *items = [MPContextMenuHelper contextMenuItemsWithItems:MPContextMenuFull];
  for(NSMenuItem *item in items) {
    [menu addItem:item];
  }
  [menu setDelegate:_menuDelegate];
  [self.entryTable setMenu:menu];
  
}

#pragma makr Action Helper

- (KdbEntry *)_clickedOrSelectedEntry {
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
  KdbEntry *selectedEntry = [self _clickedOrSelectedEntry];
  if(selectedEntry) {
    [self _copyToPasteboard:selectedEntry.password overlayInfo:MPOverlayInfoPassword name:nil];
  }
}

- (void)copyUsername:(id)sender {
  KdbEntry *selectedEntry = [self _clickedOrSelectedEntry];
  if(selectedEntry) {
    [self _copyToPasteboard:selectedEntry.username overlayInfo:MPOverlayInfoUsername name:nil];
  }
}

- (void)copyCustomField:(id)sender {
  KdbEntry *selectedEntry = [self _clickedOrSelectedEntry];
  if(selectedEntry && [selectedEntry isKindOfClass:[Kdb4Entry class]]) {
    Kdb4Entry *entry = (Kdb4Entry *)selectedEntry;
    NSUInteger index = [sender tag];
    NSAssert((index >= 0)  && (index < [entry.stringFields count]), @"Index for custom field needs to be valid");
    StringField *field = entry.stringFields[index];
    [self _copyToPasteboard:field.value overlayInfo:MPOverlayInfoCustom name:field.key];
  }
}

- (void)copyURL:(id)sender {
  KdbEntry *selectedEntry = [self _clickedOrSelectedEntry];
  if(selectedEntry) {
    [self _copyToPasteboard:selectedEntry.url overlayInfo:MPOverlayInfoURL name:nil];
  }
}

- (void)openURL:(id)sender {
  KdbEntry *selectedEntry = [self _clickedOrSelectedEntry];
  if(selectedEntry && [selectedEntry.url length] > 0) {
    NSURL *webURL = [NSURL URLWithString:selectedEntry.url];
    [[NSWorkspace sharedWorkspace] openURL:webURL];
  }
}

- (void)deleteNode:(id)sender {
  KdbEntry *entry =[self _clickedOrSelectedEntry];
  MPDocument *document = [[self windowController] document];
  [document deleteEntry:entry];
}

#pragma mark Validation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  return YES;
}

- (void)_toggleFilterSpace:(id)sender {
  NSButton *button = sender;
  NSNumber *value = self.filterButtonToMode[[button identifier]];
  MPFilterModeType toggledMode = (MPFilterModeType)[value intValue];
  switch ([button state]) {
    case NSOnState:
      self.filterMode |= toggledMode;
      break;
      
    case NSOffState:
      self.filterMode ^= toggledMode;
      break;
      
    default:
      break;
  }
}

- (void)_columnDoubleClick:(id)sender {
  if(0 == [[self.entryArrayController arrangedObjects] count]) {
    return; // No data available
  }
  NSTableColumn *column = [self.entryTable tableColumns][[self.entryTable clickedColumn]];
  NSString *identifier = [column identifier];
  if([identifier isEqualToString:MPEntryTablePasswordColumnIdentifier]) {
    [self copyPassword:nil];
  }
  else if([identifier isEqualToString:MPEntryTableUserNameColumnIdentifier]) {
    [self copyUsername:nil];
  }
  else if([identifier isEqualToString:MPEntryTableURLColumnIdentifier]) {
    if([[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyDoubleClickURLToLaunch])
      [self openURL:nil];
    else
      [self copyURL:nil];
  }
}

- (void)setFilterMode:(MPFilterModeType)newFilterMode {
  if(_filterMode != newFilterMode) {
    if(newFilterMode == MPFilterNone) {
      newFilterMode = MPFilterTitles;
    }
    _filterMode = newFilterMode;
    [self updateFilter];
  }
}

- (BOOL)_shouldFilterTitles {
  return ( MPFilterNone != (self.filterMode & MPFilterTitles));
}

- (BOOL)_shouldFilterURLs {
  return ( MPFilterNone != (self.filterMode & MPFilterUrls));
}

- (BOOL)_shouldFilterUsernames {
  return ( MPFilterNone != (self.filterMode & MPFilterUsernames));
}

@end
