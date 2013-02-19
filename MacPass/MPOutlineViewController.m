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


- (void)didOpenDocument:(NSNotification *)notification;
- (void)setupMenu;
- (void)addEntry:(id)sender;

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
                                             selector:@selector(didOpenDocument:)
                                                 name:MPDatabaseControllerDidLoadDatabaseNotification
                                               object:nil];
    [self setupMenu];
  }
  
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (void)didLoadView {
  //[[self.outlineView outlineTableColumn] setIdentifier:kColumnIdentifier];
  [self.outlineView setDataSource:self.datasource];
  [self.outlineView setDelegate:self.outlineDelegate];
  [self.outlineView setMenu:self.menu];
}

- (void)didOpenDocument:(NSNotification *)notification {
  [self.outlineView reloadData];
  MPDatabaseController *dbContoller = [MPDatabaseController defaultController];
  [self.outlineView expandItem:dbContoller.database.root expandChildren:NO];
}

- (void)setupMenu {
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

- (void)addEntry:(id)sender {
  NSLog(@"Add Entry");
}

@end
