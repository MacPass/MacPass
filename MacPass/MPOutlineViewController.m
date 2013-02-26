//
//  MPOutlineViewController.m
//  MacPass
//
//  Created by michael starke on 19.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineViewController.h"
#import "MPOutlineViewDelegate.h"
#import "MPOutlineDataSource.h"
#import "MPDatabaseController.h"
#import "MPDatabaseDocument.h"

@interface MPOutlineViewController ()

@property (assign) IBOutlet NSOutlineView *outlineView;

@property (retain) MPOutlineDataSource *datasource;
@property (retain) MPOutlineViewDelegate *outlineDelegate;
@property (retain) NSMenu *menu;


- (void)_didOpenDocument:(NSNotification *)notification;
- (void)_setupMenu;
- (void)_addEntry:(id)sender;

@end

@implementation MPOutlineViewController

- (id)init {
  return [[MPOutlineViewController alloc] initWithNibName:@"OutlineView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.outlineDelegate = [[[MPOutlineViewDelegate alloc] init] autorelease];
    self.datasource = [[[MPOutlineDataSource alloc] init] autorelease];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didOpenDocument:)
                                                 name:MPDatabaseControllerDidLoadDatabaseNotification
                                               object:nil];
    [self _setupMenu];
  }
  
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.datasource = nil;
  self.outlineDelegate = nil;
  self.menu = nil;
  [super dealloc];
}

- (void)didLoadView {
  [self.outlineView setDataSource:self.datasource];
  [self.outlineView setDelegate:self.outlineDelegate];
  [self.outlineView setMenu:self.menu];
  [self.outlineView setAllowsEmptySelection:YES];
}

- (void)_didOpenDocument:(NSNotification *)notification {
  [self.outlineView reloadData];
  MPDatabaseController *dbContoller = [MPDatabaseController defaultController];
  if(dbContoller.database) {
    [self.outlineView expandItem:dbContoller.database.root expandChildren:NO];
  }
}

- (void)clearSelection {
  [self.outlineView deselectAll:nil];
}

- (void)_setupMenu {
  NSMenu *menu = [[NSMenu allocWithZone:[NSMenu menuZone]] init];
  [menu addItemWithTitle:@"Add Group" action:@selector(addEntry:) keyEquivalent:@""];
  [menu addItem: [NSMenuItem separatorItem]];
  [menu addItemWithTitle:@"Delete" action:NULL keyEquivalent:@""];
  for(NSMenuItem *item in [menu itemArray]) {
    [item setTarget:self];
  }
  
  self.menu = menu;
  [menu release];
}

- (void)_addEntry:(id)sender {
  NSLog(@"Add Entry");
}

@end
