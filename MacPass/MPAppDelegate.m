//
//  MPAppDelegate.m
//  MacPass
//
//  Created by Michael Starke on 19.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPAppDelegate.h"

#import "MPDatabaseDocument.h"
#import "MPOutlineDataSource.h"
#import "MPOutlineViewDelegate.h"

NSString *const kColumnIdentifier = @"OutlineColumn";
NSString *const kOutlineViewIdentifier = @"OutlineView";

@interface MPAppDelegate ()
@property (assign) IBOutlet NSOutlineView *outlineView;
@property (retain) MPOutlineDataSource *datasource;
@property (retain) MPOutlineViewDelegate *outlineDelegate;
@property (retain) MPDatabaseDocument *database;
- (void)updateData;
@end

@implementation MPAppDelegate

@synthesize outlineView = _outlineView;
@synthesize window = _window;
@synthesize database = _database;
@synthesize outlineDelegate = _outlineDelegate;
@synthesize datasource = _datasource;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  _outlineDelegate = [[MPOutlineViewDelegate alloc] init];
  _datasource = [[MPOutlineDataSource alloc] init];
  [[_outlineView outlineTableColumn] setIdentifier:kColumnIdentifier];
  [_outlineView setDelegate:_outlineDelegate];
  [_outlineView setDataSource:_datasource];
  
  // register for sucessfull document loads
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:MPDidLoadDataBaseNotification object:_database];
}

- (void)updateData {
  [_outlineView reloadData];
}

@end
