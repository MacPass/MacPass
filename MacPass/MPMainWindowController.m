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
@property (assign) IBOutlet NSTextField *welcomeText;
@property (retain) NSToolbar *toolbar;

@property (retain) MPPasswordInputController *passwordInputController;
@property (retain) MPEntryViewController *entryViewController;
@property (retain) MPOutlineViewController *outlineViewController;

@property (retain) MPToolbarDelegate *toolbarDelegate;
@property (retain) MPMainWindowSplitViewDelegate *splitViewDelegate;

- (void)collapseOutlineView;
- (void)expandOutlineView;

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

#pragma mark View Handling

- (void)windowDidLoad
{
  [super windowDidLoad];
  
  [[self.welcomeText cell] setBackgroundStyle:NSBackgroundStyleRaised];
  
  const CGFloat minimumWindowWidth = MPMainWindowSplitViewDelegateMinimumContentWidth + MPMainWindowSplitViewDelegateMinimumOutlineWidth + [self.splitView dividerThickness];
  [self.window setMinSize:NSMakeSize( minimumWindowWidth, 400)];
  
  _toolbar = [[NSToolbar alloc] initWithIdentifier:@"MainWindowToolbar"];
  [self.toolbar setAllowsUserCustomization:YES];
  [self.toolbar setDelegate:self.toolbarDelegate];
  [self.window setToolbar:self.toolbar];
  
  [self.splitView setDelegate:self.splitViewDelegate];
  
  NSRect frame = [self.outlineView frame];
  [self.outlineViewController.view setFrame:frame];
  [self.outlineViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [self.splitView replaceSubview:self.outlineView with:[self.outlineViewController view]];
  [self.splitView adjustSubviews];
  
  [self setContentViewController:nil];
  [self collapseOutlineView];
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
  [self.contentView setNeedsDisplay:YES];
  [self.splitView adjustSubviews];
  /*
   Set focus AFTER having added the view
   */
  [self.window makeFirstResponder:[viewController reconmendedFirstResponder]];
}

- (void)collapseOutlineView {
  NSView *outlineView = [self.splitView subviews][0];
  if(![outlineView isHidden]) {
    [self.splitView setPosition:0 ofDividerAtIndex:0];
  }
}

- (void)expandOutlineView {
  NSView *outlineView = [self.splitView subviews][0];
  if([outlineView isHidden]) {
    [self.splitView setPosition:MPMainWindowSplitViewDelegateMinimumOutlineWidth ofDividerAtIndex:0];
  }
}

#pragma mark Actions

- (void)performFindPanelAction:(id)sender {
  [self.window makeFirstResponder:[self.toolbarDelegate.searchItem view]];
}

- (void)showMainWindow:(id)sender {
  [self showWindow:self.window];
}

- (void)openDocument:(id)sender {
 
  if(!self.passwordInputController) {
    self.passwordInputController = [[[MPPasswordInputController alloc] init] autorelease];
  }
  
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setCanChooseFiles:YES];
  [openPanel setCanCreateDirectories:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setAllowedFileTypes:@[ @"kdbx", @"kdb"]];
  [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
    if(result == NSFileHandlingPanelOKButton) {
      NSURL *file = [[openPanel URLs] lastObject];
      self.passwordInputController.fileURL = file;
      [self setContentViewController:self.passwordInputController];
    }
  }];
}

- (void)updateFilter:(id)sender {
  NSSearchField *searchField = sender;
  self.entryViewController.filter = [searchField stringValue];
}

- (void)cancelFilter:(id)sender {
  NSLog(@"Whooo");
}

#pragma mark Notifications

- (void)didOpenDocument:(NSNotification *)notification {
  [self showEntries];
}

- (void)showEntries {
  [self expandOutlineView];
  if(!self.entryViewController) {
    _entryViewController = [[MPEntryViewController alloc] init];
  }
  [self setContentViewController:self.entryViewController];
}

- (IBAction)changedFileType:(id)sender {
}
@end
