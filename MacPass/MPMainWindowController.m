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
#import "MPMainWindowDelegate.h"

NSString *const kColumnIdentifier = @"OutlineColumn";
NSString *const kOutlineViewIdentifier = @"OutlineView";


@interface MPMainWindowController ()

@property (assign) IBOutlet NSOutlineView *outlineView;
@property (retain) MPOutlineDataSource *datasource;
@property (retain) MPOutlineViewDelegate *outlineDelegate;
@property (retain) MPMainWindowDelegate *windowDelegate;

- (void)updateData;

@end

@implementation MPMainWindowController


-(id)init {
  self = [super initWithWindowNibName:@"MainWindow" owner:self];
  if( self ) {
    _windowDelegate = [[MPMainWindowDelegate alloc] init];
    _outlineDelegate = [[MPOutlineViewDelegate alloc] init];
    _datasource = [[MPOutlineDataSource alloc] init];
  }
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  /*
   Setup Connections for Outline View
   */
  
  [self.window setDelegate:self.windowDelegate];
  [[_outlineView outlineTableColumn] setIdentifier:kColumnIdentifier];
  [_outlineView setDelegate:_outlineDelegate];
}

- (void)updateData {
  [_outlineView reloadData];
}

@end
