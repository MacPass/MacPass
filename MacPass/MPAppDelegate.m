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
@end

@implementation MPAppDelegate

@synthesize outlineView = _outlineView;
@synthesize window = _window;
@synthesize outlineImage = _OutlineImage;
@synthesize outlineText = _outlineText;
@synthesize database = _database;
@synthesize outlineDelegate = _outlineDelegate;
@synthesize datasource = _datasource;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  _database = [[MPDatabaseDocument alloc] initWithFile:nil andPassword:@""];
  
  _outlineDelegate = [[MPOutlineViewDelegate alloc] init];
  _datasource = [[MPOutlineDataSource alloc] init];
  [_outlineView setDelegate:_outlineDelegate];
  [_outlineView setDataSource:_datasource];
  // show open dialog?
  // show main window?
}

@end
