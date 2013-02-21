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

NSString *const MPEntryTableUserNameColumnIdentifier = @"MPUserNameColumnIdentifier";
NSString *const MPEntryTableTitleColumnIdentifier = @"MPTitleColumnIdentifier";
NSString *const MPEntryTablePasswordColumnIdentifier = @"MPPasswordColumnIdentifier";
NSString *const MPEntryTableParentColumnIdentifier = @"MPParentColumnIdentifier";

NSString *const _MPTableImageCellView = @"ImageCell";
NSString *const _MPTableStringCellView = @"StringCell";
NSString *const _MPTAbleSecurCellView = @"PasswordCell";

@interface MPEntryViewController ()

@property (retain) NSArrayController *entryArrayController;
@property (retain) NSArray *filteredEntries;
@property (assign) IBOutlet NSTableView *entryTable;
@property (assign) IBOutlet NSView *statusBar;
@property (assign) IBOutlet NSTextField *searchLabelTextField;
@property (assign) BOOL isStatusBarVisible;
@property (retain) IBOutlet NSLayoutConstraint *statusBarToTop;
@property (retain) IBOutlet NSLayoutConstraint *tableToTop;


- (BOOL)hasFilter;
- (void)updateFilter;
- (void)didChangeGroupSelectionInOutlineView:(NSNotification *)notification;
- (void)showStatusBarAnimated:(BOOL)animate;
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
    _entryArrayController = [[NSArrayController alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeGroupSelectionInOutlineView:)
                                                 name:MPOutlineViewDidChangeGroupSelection
                                               object:nil];
  }
  return self;
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
  
  [parentColumn setIdentifier:MPEntryTableParentColumnIdentifier];
  [titleColumn setIdentifier:MPEntryTableTitleColumnIdentifier];
  [userNameColumn setIdentifier:MPEntryTableUserNameColumnIdentifier];
  [passwordColumn setIdentifier:MPEntryTablePasswordColumnIdentifier];
  
  [[parentColumn headerCell] setStringValue:@"Group"];
  [[titleColumn headerCell] setStringValue:@"Title"];
  [[userNameColumn headerCell] setStringValue:@"Username"];
  [[passwordColumn headerCell] setStringValue:@"Password"];
  
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
    return view;
  }
  
  if( isPasswordColum ) {
    view = [tableView makeViewWithIdentifier:_MPTAbleSecurCellView owner:self];
    [[view textField] setStringValue:entry.password];
    return view;
  }
  
  if( isUsernameColumn ) {
    view = [tableView makeViewWithIdentifier:_MPTableStringCellView owner:self];
    [[view textField] setStringValue:entry.username];
    return view;
  }
  
  return view;
}

#pragma mark Notifications
- (void)didChangeGroupSelectionInOutlineView:(NSNotification *)notification {
  
  self.filter = @""; // will update the reast automatically
  
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

- (void)updateFilter {
  MPDatabaseDocument *openDatabase = [MPDatabaseController defaultController].database;
  if(openDatabase && [self hasFilter]) {
    [self showStatusBarAnimated:YES];
    
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
      
      NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"SELF.title CONTAINS[cd] %@", self.filter];
      self.filteredEntries = [[openDatabase.root childEntries] filteredArrayUsingPredicate:filterPredicate];
      
      dispatch_sync(dispatch_get_main_queue(), ^{
        [self.entryArrayController setContent:self.filteredEntries];
        [[self.entryTable tableColumnWithIdentifier:MPEntryTableParentColumnIdentifier] setHidden:NO];
      });
    });
  }
  else {
    [self.entryArrayController setContent:nil];
    self.filteredEntries = nil;
    [[self.entryTable tableColumnWithIdentifier:MPEntryTableParentColumnIdentifier] setHidden:YES];
    [self hideStatusBarAnimated:YES];
  }
}

#pragma mark Animation

- (void)showStatusBarAnimated:(BOOL)animate {
  
  if(self.isStatusBarVisible) {
    return; // nothign to to
  }
  self.isStatusBarVisible = YES;
  self.statusBarToTop.constant = 0;
  self.tableToTop.constant = [self.statusBar frame].size.height;
    
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
  
  if(!self.isStatusBarVisible) {
    return; // nothing to do;
  }
  
  self.isStatusBarVisible = NO;
  self.statusBarToTop.constant = -[self.statusBar frame].size.height;
  self.tableToTop.constant = -1;
  
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


@end
