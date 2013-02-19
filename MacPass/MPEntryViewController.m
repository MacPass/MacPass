//
//  MPEntryViewController.m
//  MacPass
//
//  Created by michael starke on 18.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPEntryViewController.h"
#import "MPOutlineViewDelegate.h"

NSString *const _MPUserNameColumnIdentifier = @"MPUserNameColumnIdentifier";
NSString *const _MPTitleColumnIdentifier = @"MPTitleColumnIdentifier";
NSString *const _MPPasswordColumnIdentifier = @"MPPasswordColumnIdentifier";

@interface MPEntryViewController ()

@property (retain) NSArrayController *entryArrayController;
@property (assign) IBOutlet NSTableView *entryTable;

- (void)didChangeGroupSelectionInOutlineView:(NSNotification *)notification;

@end

@implementation MPEntryViewController

- (id)init {
  return [[MPEntryViewController alloc] initWithNibName:@"EntryView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self) {
    _entryArrayController = [[NSArrayController alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeGroupSelectionInOutlineView:)
                                                 name:MPOutlineViewDidChangeGroupSelection
                                               object:nil];
  }
  return self;
}

- (void)didLoadView {
  NSTableColumn *nameColumn = [self.entryTable tableColumns][0];
  NSTableColumn *userNameColumn = [self.entryTable tableColumns][1];
  NSTableColumn *passwordColumn = [self.entryTable tableColumns][2];
  
  [nameColumn setIdentifier:_MPTitleColumnIdentifier];
  [userNameColumn setIdentifier:_MPUserNameColumnIdentifier];
  [passwordColumn setIdentifier:_MPPasswordColumnIdentifier];
  
  [[nameColumn headerCell] setStringValue:@"Title"];
  [[userNameColumn headerCell] setStringValue:@"Username"];
  [[passwordColumn headerCell] setStringValue:@"Password"];
  
  [nameColumn bind:NSValueBinding toObject:self.entryArrayController withKeyPath:@"arrangedObjects.title" options:nil];
  [userNameColumn bind:NSValueBinding toObject:self.entryArrayController withKeyPath:@"arrangedObjects.username" options:nil];
  [passwordColumn bind:NSValueBinding toObject:self.entryArrayController withKeyPath:@"arrangedObjects.password" options:nil];
}

- (void)didChangeGroupSelectionInOutlineView:(NSNotification *)notification {
  MPOutlineViewDelegate *delegate = [notification object];
  KdbGroup *group = delegate.selectedGroup;
  if(group) {
    [self.entryArrayController bind:NSContentArrayBinding toObject:group withKeyPath:@"entries" options:nil];
  }
  else {
    [self.entryArrayController setContent:nil];
  }
}

@end
