//
//  MPMainWindowController.m
//  MacPass
//
//  Created by Michael Starke on 24.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPMainWindowController.h"
#import "MPDatabaseController.h"
#import "MPPasswordInputController.h"
#import "MPEntryViewController.h"
#import "MPToolbarDelegate.h"
#import "MPOutlineViewController.h"
#import "MPMainWindowSplitViewDelegate.h"

@interface MPMainWindowController ()


@property (assign) IBOutlet NSView *outlineView;
@property (assign) IBOutlet NSSplitView *splitView;
@property (assign) IBOutlet NSView *contentView;

@property (retain) IBOutlet NSView *welcomeView;
@property (retain) NSToolbar *toolbar;

@property (retain) MPPasswordInputController *passwordInputController;
@property (retain) MPEntryViewController *entryViewController;
@property (retain) MPOutlineViewController *outlineViewController;

@property (retain) MPToolbarDelegate *toolbarDelegate;
@property (retain) MPMainWindowSplitViewDelegate *splitViewDelegate;

@end

@implementation MPMainWindowController

-(id)init {
  self = [super initWithWindowNibName:@"MainWindow" owner:self];
  if( self ) {
    _toolbarDelegate = [[MPToolbarDelegate alloc] init];
    _outlineViewController = [[MPOutlineViewController alloc] init];
    _splitViewDelegate = [[MPMainWindowSplitViewDelegate alloc] init];
    
    [[NSBundle mainBundle] loadNibNamed:@"WelcomeView" owner:self topLevelObjects:NULL];
    [self.welcomeView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didOpenDocument:)
                                                 name:MPDatabaseControllerDidLoadDatabaseNotification
                                               object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  const CGFloat minimumWindowWidth = MPMainWindowSplitViewDelegateMinimumContentWidth + MPMainWindowSplitViewDelegateMinimumOutlineWidth + [self.splitView dividerThickness];
  [self.window setMinSize:NSMakeSize( minimumWindowWidth, 400)];
  
  _toolbar = [[NSToolbar alloc] initWithIdentifier:@"MainWindowToolbar"];
  [self.toolbar setAllowsUserCustomization:YES];
  [self.toolbar setDelegate:self.toolbarDelegate];
  [self.window setToolbar:self.toolbar];
  
  [self.splitView setDelegate:self.splitViewDelegate];
  
  NSRect frame = [self.outlineView frame];
//  frame.size.height -= 1;
//  frame.origin.y = 10;
  [self.outlineViewController.view setFrame:frame];
  [self.outlineViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [self.splitView replaceSubview:self.outlineView with:[self.outlineViewController view]];
  [self.splitView adjustSubviews];
  [self setContentViewController:nil];
}

- (void)setContentViewController:(MPViewController *)viewController {
  NSView *newContentView = self.welcomeView;
  if(viewController && viewController.view) {
    newContentView = viewController.view;
  }
  /*
   Set correct size and resizing for view
   */
  [newContentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  NSSize frameSize = [self.contentView frame].size;
  [newContentView setFrame:NSMakeRect(0,0, frameSize.width, frameSize.height)];
  
  /*
   Add or replace subview
   */
  NSArray *subViews = [self.contentView subviews];
  BOOL hasSubViews = ([subViews count] > 0);
  if(hasSubViews) {
    NSView *subView = subViews[0];
    assert(subView);
    [self.contentView replaceSubview:subView with:newContentView];
  }
  else {
    [self.contentView addSubview:newContentView];
  }
  [self.splitView adjustSubviews];
  /*
   Set focus AFTER having added the view
   */
  [self.window makeFirstResponder:[viewController reconmendedFirstResponder]];
}

#pragma mark Actions

- (void)openDocument:(id)sender {
  
  if(!self.passwordInputController) {
    self.passwordInputController = [[[MPPasswordInputController alloc] init] autorelease];
  }
  
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setCanChooseFiles:YES];
  [openPanel setCanCreateDirectories:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
    if(result == NSFileHandlingPanelOKButton) {
      NSURL *file = [[openPanel URLs] lastObject];
      self.passwordInputController.fileURL = file;
      [self setContentViewController:self.passwordInputController];
    }
  }];
}

#pragma mark Notifications

- (void)didOpenDocument:(NSNotification *)notification {
  [self showEntries];
}

- (void)showEntries {
  if(!self.entryViewController) {
    _entryViewController = [[MPEntryViewController alloc] init];
  }
  [self setContentViewController:self.entryViewController];
}

@end
