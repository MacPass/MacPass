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
#import "MPDatabaseController.h"
#import "MPDatabaseDocument.h"

NSString *const MPMainWindowControllerPasswordKey = @"MPMainWindowControllerPasswordKey";
NSString *const MPMainWindowControllerKeyfileKey = @"MPMainWindowControllerKeyfileKey";

NSString *const kColumnIdentifier = @"OutlineColumn";
NSString *const kOutlineViewIdentifier = @"OutlineView";


@interface MPMainWindowController ()

@property (assign) IBOutlet NSOutlineView *outlineView;
@property (retain) IBOutlet NSView *passwordView;

@property (assign) IBOutlet NSTextField *passwordTextField;
@property (assign) IBOutlet NSPathControl *keyPathControl;
@property (assign) IBOutlet NSView *contentView;
@property (retain) IBOutlet NSView *welcomeView;

@property (retain) NSURL *openFile;
@property (retain) MPOutlineDataSource *datasource;
@property (retain) MPOutlineViewDelegate *outlineDelegate;
@property (retain) MPMainWindowDelegate *windowDelegate;

- (IBAction)usePassword:(id)sender;
- (void)updateData;

@end

@implementation MPMainWindowController

-(id)init {
  self = [super initWithWindowNibName:@"MainWindow" owner:self];
  if( self ) {
    NSArray *topLevelObjects;
    self.windowDelegate = [[[MPMainWindowDelegate alloc] init] autorelease];
    self.outlineDelegate = [[[MPOutlineViewDelegate alloc] init] autorelease];
    self.datasource = [[[MPOutlineDataSource alloc] init] autorelease];
    [[NSBundle mainBundle] loadNibNamed:@"WelcomeView" owner:self topLevelObjects:&topLevelObjects];
    [self.welcomeView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
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
  [[self.outlineView outlineTableColumn] setIdentifier:kColumnIdentifier];
  [self.outlineView setDelegate:self.outlineDelegate];
  [self.outlineView setDataSource:self.datasource];

  
  /*
   Add Welcome Screen
   */
  NSSize frameSize = [self.contentView frame].size;
  [self.contentView setFrame:NSMakeRect(0,0, frameSize.width, frameSize.height)];
  [self.contentView addSubview:self.welcomeView];
  
}

- (void)updateData {
  [self.outlineView reloadData];
  MPDatabaseController *dbContoller = [MPDatabaseController defaultController];
  [self.outlineView expandItem:dbContoller.database.root expandChildren:NO];
}

- (void)presentPasswordInput:(NSURL *)file {
  NSArray *topLevelObjects;
  self.openFile = file;
  [[NSBundle mainBundle] loadNibNamed:@"PasswordView" owner:self topLevelObjects:&topLevelObjects];
  [self.passwordView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  NSSize frameSize = [self.contentView frame].size;
  [self.passwordView setFrame:NSMakeRect(0,0, frameSize.width, frameSize.height)];
  [self.contentView setAutoresizesSubviews:YES];
  [self.contentView replaceSubview:self.welcomeView with:self.passwordView];
  [self.window makeFirstResponder:self.passwordView];
}

- (void)usePassword:(id)sender {
  NSString *password = [self.passwordTextField stringValue];
  
  [[MPDatabaseController defaultController] openDatabase:self.openFile password:password keyfile:nil];
  [self updateData];
}

@end
