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
#import "KdbGroup+MPAdditions.h"

#import <QuartzCore/QuartzCore.h>

#define STATUS_BAR_ANIMATION_TIME 0.2

typedef enum {
  MPFilterNone = 0,
  MPFilterUrls = 2,
  MPFilterUsernames = 4,
  MPFilterTitles = 8,
} MPFilterModeType;

NSString *const MPEntryTableUserNameColumnIdentifier = @"MPUserNameColumnIdentifier";
NSString *const MPEntryTableTitleColumnIdentifier = @"MPTitleColumnIdentifier";
NSString *const MPEntryTablePasswordColumnIdentifier = @"MPPasswordColumnIdentifier";
NSString *const MPEntryTableParentColumnIdentifier = @"MPParentColumnIdentifier";
NSString *const MPEntryTableURLColumnIdentifier = @"MPEntryTableURLColumnIdentifier";

NSString *const _MPTableImageCellView = @"ImageCell";
NSString *const _MPTableStringCellView = @"StringCell";
NSString *const _MPTAbleSecurCellView = @"PasswordCell";

NSString *const _toggleSearchURLButton = @"SearchURL";
NSString *const _toggleSearchTitleButton = @"SearchTitle";
NSString *const _toggleSearchUsernameButton = @"SearchUsername";

@interface MPEntryViewController ()

@property (retain) NSArrayController *entryArrayController;
@property (retain) NSArray *filteredEntries;
@property (retain) IBOutlet NSView *filterBar;
@property (assign) IBOutlet NSTableView *entryTable;
@property (assign) IBOutlet NSTextField *searchLabelTextField;
@property (assign) BOOL isStatusBarVisible;
@property (retain) IBOutlet NSLayoutConstraint *tableToTop;

@property (assign) IBOutlet NSButton *searchTitleButton;
@property (assign) IBOutlet NSButton *searchUsernameButton;
@property (assign) IBOutlet NSButton *searchURLButton;

@property (assign, nonatomic) MPFilterModeType filterMode;
@property (retain, nonatomic) NSDictionary *filterButtonToMode;

- (IBAction)toggleFilterSpace:(id)sender;

- (BOOL)shouldFilterURLs;
- (BOOL)shouldFilterTitles;
- (BOOL)shouldFilterUsernames;

- (BOOL)hasFilter;
- (void)updateFilter;
- (void)setupFilterBar;
- (void)didChangeGroupSelectionInOutlineView:(NSNotification *)notification;
- (void)showFilterBarAnimated:(BOOL)animate;
- (void)hideStatusBarAnimated:(BOOL)animate;

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
    _filterButtonToMode = [@{ _toggleSearchUsernameButton : @(MPFilterUsernames),
                           _toggleSearchTitleButton : @(MPFilterTitles),
                           _toggleSearchURLButton : @(MPFilterUrls)
                           } retain];
    _entryArrayController = [[NSArrayController alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeGroupSelectionInOutlineView:)
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
  [self hideStatusBarAnimated:NO];
  [[self.searchLabelTextField cell] setBackgroundStyle:NSBackgroundStyleRaised];
  
  [self.entryTable setDelegate:self];
  
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
    [[view imageView] setImage:[MPIconHelper randomIcon]];
    if( isTitleColumn ) {
      [[view textField] setStringValue:entry.title];
    }
    else {
      [[view textField] setStringValue:entry.parent.name];
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
- (void)didChangeGroupSelectionInOutlineView:(NSNotification *)notification {
  
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

- (void)clearFilter {
  self.filter = nil;
  [[self.entryTable tableColumnWithIdentifier:MPEntryTableParentColumnIdentifier] setHidden:YES];
  [self hideStatusBarAnimated:YES];
}

- (void)updateFilter {
  MPDatabaseDocument *openDatabase = [MPDatabaseController defaultController].database;
  if(openDatabase) {
    [self showFilterBarAnimated:YES];
    
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
      
      NSMutableArray *prediactes = [NSMutableArray arrayWithCapacity:3];
      if( [self shouldFilterTitles] ) {
        [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.title CONTAINS[cd] %@", self.filter]];
      }
      if( [self shouldFilterUsernames] ) {
        [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.username CONTAINS[cd] %@", self.filter]];
      }
      if( [self shouldFilterURLs] ) {
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
    [self.searchURLButton setIdentifier:_toggleSearchURLButton];
    [self.searchUsernameButton setIdentifier:_toggleSearchUsernameButton];
    [self.searchTitleButton setIdentifier:_toggleSearchTitleButton];
  }
}

#pragma mark Animation

- (void)showFilterBarAnimated:(BOOL)animate {
  
  animate = NO;
  
  if(!self.filterBar) {
    [self setupFilterBar];
  }
  /*
   Make sure the buttons are set correctyl every time
   */
  [self.searchTitleButton setState:[self shouldFilterTitles] ? NSOnState : NSOffState];
  [self.searchURLButton setState:[self shouldFilterURLs] ? NSOnState : NSOffState ];
  [self.searchUsernameButton setState:[self shouldFilterUsernames] ? NSOnState : NSOffState];
  
  if(self.isStatusBarVisible) {
    return; // nothign to to
  }
  
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

- (void)hideStatusBarAnimated:(BOOL)animate {
  
  animate = NO;
 
  if(!self.isStatusBarVisible) {
    return; // nothing to do;
  }
  
  self.isStatusBarVisible = NO;
  self.tableToTop.constant = -1;
  [self.filterBar removeFromSuperview];
  
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

#pragma mark Actions

- (void)toggleFilterSpace:(id)sender {
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

- (BOOL)shouldFilterTitles {
  return ( MPFilterNone != (self.filterMode & MPFilterTitles));
}

- (BOOL)shouldFilterURLs {
  return ( MPFilterNone != (self.filterMode & MPFilterUrls));
}

- (BOOL)shouldFilterUsernames {
  return ( MPFilterNone != (self.filterMode & MPFilterUsernames));
}

@end
