//
//  MPEntryViewController.m
//  MacPass
//
//  Created by michael starke on 18.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPEntryViewController.h"
#import "MPOutlineViewDelegate.h"
#import "MPDatabaseController.h"
#import "MPDatabaseDocument.h"
#import "MPIconHelper.h"
#import "MPMainWindowController.h"
#import "MPPasteBoardController.h"
#import "KdbGroup+MPAdditions.h"

#import <QuartzCore/QuartzCore.h>

#define STATUS_BAR_ANIMATION_TIME 0.2

typedef enum {
  MPFilterNone = 0,
  MPFilterUrls = 2,
  MPFilterUsernames = 4,
  MPFilterTitles = 8,
} MPFilterModeType;

typedef enum {
  MPCopyUsername,
  MPCopyPassword,
  MPCopyURL,
  MPCopyWholeEntry,
} MPCopyContentTypeTag;

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

@interface MPEntryViewController ()

@property (retain) NSArrayController *entryArrayController;
@property (retain) NSArray *filteredEntries;
@property (retain) IBOutlet NSView *filterBar;
@property (retain) IBOutlet NSView *pathBar;
@property (assign) IBOutlet NSTableView *entryTable;
@property (assign) BOOL isStatusBarVisible;
@property (assign) IBOutlet NSLayoutConstraint *tableToTop;
@property (assign) IBOutlet NSLayoutConstraint *tableToBottom;
@property (assign) IBOutlet NSButton *filterDoneButton;

@property (assign) IBOutlet NSButton *filterTitleButton;
@property (assign) IBOutlet NSButton *filterUsernameButton;
@property (assign) IBOutlet NSButton *filterURLButton;
@property (assign) IBOutlet NSTextField *filterLabelTextField;

@property (assign, nonatomic) MPFilterModeType filterMode;
@property (retain, nonatomic) NSDictionary *filterButtonToMode;

- (IBAction)_toggleFilterSpace:(id)sender;

- (BOOL)_shouldFilterURLs;
- (BOOL)_shouldFilterTitles;
- (BOOL)_shouldFilterUsernames;

- (BOOL)hasFilter;
- (void)updateFilter;
- (void)setupFilterBar;
- (void)setupPathBar;
- (void)_setupEntryMenu;
- (void)_didChangeGroupSelectionInOutlineView:(NSNotification *)notification;
- (void)_showFilterBarAnimated:(BOOL)animate;
- (void)_hideStatusBarAnimated:(BOOL)animate;

- (void)_copyEntryData:(id)sender;

@end

@implementation MPEntryViewController


- (id)init {
  return [[MPEntryViewController alloc] initWithNibName:@"EntryView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self) {
    _isStatusBarVisible = YES;
    _filterMode = MPFilterTitles;
    _filterButtonToMode = [@{ _toggleFilterUsernameButton : @(MPFilterUsernames),
                           _toggleFilterTitleButton : @(MPFilterTitles),
                           _toggleFilterURLButton : @(MPFilterUrls)
                           } retain];
    _entryArrayController = [[NSArrayController alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didChangeGroupSelectionInOutlineView:)
                                                 name:MPOutlineViewDidChangeGroupSelection
                                               object:nil];
  }
  return self;
}

- (void)dealloc {
  self.entryArrayController = nil;
  self.filteredEntries = nil;
  self.filterBar = nil;
  self.tableToTop = nil;
  self.filterButtonToMode = nil;
  [super dealloc];
}

- (void)didLoadView {
  [self.view setWantsLayer:YES];
  [self _hideStatusBarAnimated:NO];
  
  [self.entryTable setDelegate:self];
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
  
  [[parentColumn headerCell] setStringValue:@"Group"];
  [[titleColumn headerCell] setStringValue:@"Title"];
  [[userNameColumn headerCell] setStringValue:@"Username"];
  [[passwordColumn headerCell] setStringValue:@"Password"];
  [[urlColumn headerCell] setStringValue:@"URL"];
  
  [self.entryTable bind:NSContentBinding toObject:self.entryArrayController withKeyPath:@"arrangedObjects" options:nil];
  
  [parentColumn setHidden:YES];
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
      [[view textField] setStringValue:entry.title];
      [[view imageView] setImage:[MPIconHelper icon:(MPIconType)entry.image]];
    }
    else {
      [[view textField] setStringValue:entry.parent.name];
      [[view imageView] setImage:[MPIconHelper icon:(MPIconType)entry.parent.image]];
    }
  }
  else if( isPasswordColum ) {
    view = [tableView makeViewWithIdentifier:_MPTAbleSecurCellView owner:self];
    [[view textField] setStringValue:entry.password];
  }
  else if( isUsernameColumn || isURLColumn ) {
    view = [tableView makeViewWithIdentifier:_MPTableStringCellView owner:self];
    if(isURLColumn) {
      [[view textField] setStringValue:entry.url];
    }
    else {
      [[view textField] setStringValue:entry.username];
    }
  }
  
  return view;
}

#pragma mark Notifications
- (void)_didChangeGroupSelectionInOutlineView:(NSNotification *)notification {
  
  if([self hasFilter]) {
    return;
  }
  [self clearFilter];
  MPOutlineViewDelegate *delegate = [notification object];
  KdbGroup *group = delegate.selectedGroup;
  if(group) {
    [self.entryArrayController bind:NSContentArrayBinding toObject:group withKeyPath:@"entries" options:nil];
  }
  else {
    [self.entryArrayController setContent:nil];
  }
}

#pragma mark Filtering

- (BOOL)hasFilter {
  return ([self.filter length] > 0);
}

- (void)setFilter:(NSString *)filter {
  if(_filter != filter) {
    [_filter release];
    _filter = [filter retain];
    [self updateFilter];
  }
}

- (void)deselectAll:(id)sender {
  [self.entryTable deselectAll:self];
}

- (void)clearFilter {
  self.filter = nil;
  [[self.entryTable tableColumnWithIdentifier:MPEntryTableParentColumnIdentifier] setHidden:YES];
  [self _hideStatusBarAnimated:YES];
}

- (void)updateFilter {
  MPDatabaseDocument *openDatabase = [MPDatabaseController defaultController].database;
  if(openDatabase) {
    [self _showFilterBarAnimated:YES];
    
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
      
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
      self.filteredEntries = [[openDatabase.root childEntries] filteredArrayUsingPredicate:fullFilter];
      
      dispatch_sync(dispatch_get_main_queue(), ^{
        [self.entryArrayController setContent:self.filteredEntries];
        [[self.entryTable tableColumnWithIdentifier:MPEntryTableParentColumnIdentifier] setHidden:NO];
      });
    });
  }
  else {
    [self.entryArrayController setContent:nil];
    self.filteredEntries = nil;
  }
}

- (void)setupFilterBar {
  if(!self.filterBar) {
    [[NSBundle mainBundle] loadNibNamed:@"FilterBar" owner:self topLevelObjects:nil];
    [self.filterBar setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
    [self.filterURLButton setIdentifier:_toggleFilterURLButton];
    [self.filterUsernameButton setIdentifier:_toggleFilterUsernameButton];
    [self.filterTitleButton setIdentifier:_toggleFilterTitleButton];
    [[self.filterLabelTextField cell] setBackgroundStyle:NSBackgroundStyleRaised];
    [self.filterDoneButton setAction:@selector(clearFilter:)];
    [self.filterDoneButton setTarget:nil];
  }
}

- (void)setupPathBar {
  if(!self.pathBar) {
    [[NSBundle mainBundle] loadNibNamed:@"PathBar" owner:self topLevelObjects:nil];
    [self.pathBar setAutoresizingMask:NSViewWidthSizable|NSViewMaxYMargin];
    
  }
}

#pragma mark Animation

- (void)_showFilterBarAnimated:(BOOL)animate {
  
  animate = NO;
  
  if(!self.filterBar) {
    [self setupFilterBar];
  }
  /*
   Make sure the buttons are set correctyl every time
   */
  [self.filterTitleButton setState:[self _shouldFilterTitles] ? NSOnState : NSOffState];
  [self.filterURLButton setState:[self _shouldFilterURLs] ? NSOnState : NSOffState ];
  [self.filterUsernameButton setState:[self _shouldFilterUsernames] ? NSOnState : NSOffState];
  
  if(self.isStatusBarVisible) {
    return; // nothign to to
  }
  
  [((MPMainWindowController *)[[self.view window] windowController]) clearOutlineSelection:nil];
  self.isStatusBarVisible = YES;
  self.tableToTop.constant = [self.filterBar frame].size.height;
  
  [self.view addSubview:self.filterBar];
  NSRect filterFrame = [self.filterBar frame];
  filterFrame.origin.y = [self.view frame].size.height - filterFrame.size.height;
  filterFrame.size.width = [self.view frame].size.width;
  [self.filterBar setFrame:filterFrame];
  
  if(animate) {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext* context) {
      context.duration = STATUS_BAR_ANIMATION_TIME;
      context.allowsImplicitAnimation = YES;
      [self.view layoutSubtreeIfNeeded];
    } completionHandler:nil] ;
  }
  else {
    [self.view layoutSubtreeIfNeeded];
  }
}

- (void)_hideStatusBarAnimated:(BOOL)animate {
  
  
  animate = NO;
 
  if(!self.isStatusBarVisible) {
    return; // nothing to do;
  }
  
  self.isStatusBarVisible = NO;
  self.tableToTop.constant = -1;
  [self.filterBar removeFromSuperviewWithoutNeedingDisplay];
  
  if(animate) {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext* context) {
      context.duration = STATUS_BAR_ANIMATION_TIME;
      context.allowsImplicitAnimation = YES;
      [self.view layoutSubtreeIfNeeded];
    } completionHandler:nil] ;
  }
  else {
    [self.view layoutSubtreeIfNeeded];
  }
}

#pragma mark EntryMenu

- (void)_setupEntryMenu {
  NSMenu *menu = [[NSMenu allocWithZone:[NSMenu menuZone]] init];
  NSMenuItem *copyUserItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Copy Username"
                                                                                  action:@selector(_copyEntryData:)
                                                                           keyEquivalent:@"C"];
  [copyUserItem setTag:MPCopyUsername];
  [copyUserItem setTarget:self];
  NSMenuItem *copyPasswordItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Copy Password"
                                                                                      action:@selector(_copyEntryData:)
                                                                               keyEquivalent:@"c"];
  [copyPasswordItem setTag:MPCopyPassword];
  [copyPasswordItem setTarget:self];

  [menu addItem:copyUserItem];
  [menu addItem:copyPasswordItem];
  [copyUserItem release];
  [copyPasswordItem release];
  
  [self.entryTable setMenu:menu];
  [menu release];
}

#pragma mark Actions

- (void)_copyEntryData:(id)sender {

  NSInteger selectedRow = [self.entryTable selectedRow];
  if(selectedRow > [[self.entryArrayController arrangedObjects] count]) {
    return;
  }
  KdbEntry *selectedEntry = [self.entryArrayController arrangedObjects][selectedRow];
  
  if([sender respondsToSelector:@selector(tag)]) {
    MPCopyContentTypeTag contentTag = (MPCopyContentTypeTag)[sender tag];
    SEL contentTypeSelector = @selector(description);
    switch (contentTag) {
      case MPCopyPassword:
        contentTypeSelector = @selector(password);
        break;
        
      case MPCopyUsername:
        contentTypeSelector = @selector(username);
        break;
        
      case MPCopyURL:
        contentTypeSelector = @selector(URL);
        break;
        
      case MPCopyWholeEntry:
      default:
        break;
    }
    [[MPPasteBoardController defaultController] copyObjects:@[ [selectedEntry performSelector:contentTypeSelector] ]];
  }

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
