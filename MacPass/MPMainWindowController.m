//
//  MPMainWindowController.m
//  MacPass
//
//  Created by Michael Starke on 24.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPMainWindowController.h"
#import "MPOutlineDataSource.h"
#import "MPOutlineViewDelegate.h"
#import "MPDatabaseDocument.h"

NSString *const kColumnIdentifier = @"OutlineColumn";
NSString *const kOutlineViewIdentifier = @"OutlineView";


@interface MPMainWindowController ()
@property (assign) IBOutlet NSOutlineView *outlineView;
@property (retain) MPOutlineDataSource *datasource;
@property (retain) MPOutlineViewDelegate *outlineDelegate;
@property (retain) MPDatabaseDocument *database;
- (void)updateData;
@end

@implementation MPMainWindowController


-(id)init {
  return [super initWithWindowNibName:@"MainWindow" owner:self];
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  
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

- (void)newDocument:(id)sender {
  NSLog(@"New");
}

- (void)performClose:(id)sender {
  NSLog(@"Close");
}

- (void)openDocument:(id)sender {
  NSLog(@"OpenDocument");
}

@end
