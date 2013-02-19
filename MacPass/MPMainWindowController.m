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

@interface MPMainWindowController ()

@property (assign) IBOutlet NSToolbar *toolbar;
@property (assign) IBOutlet NSView *outlineView;
@property (assign) IBOutlet NSSplitView *splitView;
@property (assign) IBOutlet NSView *contentView;

@property (retain) IBOutlet NSView *welcomeView;

@property (retain) MPPasswordInputController *passwordInputController;
@property (retain) MPEntryViewController *entryViewController;
@property (retain) MPOutlineViewController *outlineViewController;

@property (retain) MPToolbarDelegate *toolbarDelegate;

@end

@implementation MPMainWindowController

-(id)init {
  self = [super initWithWindowNibName:@"MainWindow" owner:self];
  if( self ) {
    self.toolbarDelegate = [[[MPToolbarDelegate alloc] init] autorelease];
    self.outlineViewController = [[[MPOutlineViewController alloc] init] autorelease];
    
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
  [self.toolbar setDelegate:self.toolbarDelegate];
  
  NSRect frame = [self.outlineView frame];
  frame.size.height -= 1;
  frame.origin.y = 10;
  [self.outlineViewController.view setFrame:frame];
  [self.outlineViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [self.splitView replaceSubview:self.outlineView with:self.outlineViewController.view];
  
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
  /*
   Set focus AFTER having added the view
   */
  [self.window makeFirstResponder:[viewController reconmendedFirstResponder]];
}

- (void)didOpenDocument:(NSNotification *)notification {
  [self showEntries];
}


- (void)openDocument {
  
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

- (void)showEntries {
  if(!self.entryViewController) {
    self.entryViewController = [[[MPEntryViewController alloc] init] autorelease];
  }
  [self setContentViewController:self.entryViewController];
}

@end
