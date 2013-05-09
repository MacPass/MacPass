//
//  MPMainWindowController.m
//  MacPass
//
//  Created by Michael Starke on 24.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocumentWindowController.h"
#import "MPDatabaseController.h"
#import "MPDatabaseDocument.h"
#import "MPPasswordInputController.h"
#import "MPEntryViewController.h"
#import "MPPasswordEditViewController.h"
#import "MPToolbarDelegate.h"
#import "MPOutlineViewController.h"
#import "MPMainWindowSplitViewDelegate.h"
#import "MPInspectorTabViewController.h"
#import "MPAppDelegate.h"

@interface MPDocumentWindowController ()

@property (assign) IBOutlet NSView *outlineView;
@property (assign) IBOutlet NSSplitView *splitView;
@property (assign) IBOutlet NSView *contentView;
@property (assign) IBOutlet NSView *inspectorView;

@property (retain) IBOutlet NSView *welcomeView;
@property (assign) IBOutlet NSTextField *welcomeText;
@property (retain) NSToolbar *toolbar;

@property (retain) MPPasswordInputController *passwordInputController;
@property (retain) MPPasswordEditViewController *passwordEditController;
@property (retain) MPEntryViewController *entryViewController;
@property (retain) MPOutlineViewController *outlineViewController;
@property (retain) MPInspectorTabViewController *inspectorTabViewController;

@property (retain) MPToolbarDelegate *toolbarDelegate;
@property (retain) MPMainWindowSplitViewDelegate *splitViewDelegate;

- (void)_setContentViewController:(MPViewController *)viewController;
- (void)_updateWindowTitle;

/* window reszing and content checks */
- (BOOL)_windowsIsLargeEnoughForInspectorView;
- (void)_resizeWindowForInspectorView;

@end

@implementation MPDocumentWindowController

-(id)init {
  self = [super initWithWindowNibName:@"MainWindow" owner:self];
  if( self ) {
    _toolbarDelegate = [[MPToolbarDelegate alloc] init];
    _outlineViewController = [[MPOutlineViewController alloc] init];
    _inspectorTabViewController = [[MPInspectorTabViewController alloc] init];
    _splitViewDelegate = [[MPMainWindowSplitViewDelegate alloc] init];
    _passwordEditController = [[MPPasswordEditViewController alloc] init];
    
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
  [_welcomeView release];
  [_welcomeText release];
  [_toolbar release];
  
  [_passwordInputController release];
  [_entryViewController release];
  [_outlineViewController release];
  [_inspectorTabViewController release];
  [_creationViewController release];
  
  [_toolbarDelegate release];
  [_splitViewDelegate release];
  [super dealloc];
}

#pragma mark View Handling

- (void)windowDidLoad
{
  [super windowDidLoad];
  [self _updateWindowTitle];
  
  [[self.welcomeText cell] setBackgroundStyle:NSBackgroundStyleRaised];
  CGFloat minWidht = MPMainWindowSplitViewDelegateMinimumContentWidth + MPMainWindowSplitViewDelegateMinimumOutlineWidth + [self.splitView dividerThickness];
  [self.window setMinSize:NSMakeSize( minWidht, 400)];
  
  _toolbar = [[NSToolbar alloc] initWithIdentifier:@"MainWindowToolbar"];
  [self.toolbar setAllowsUserCustomization:YES];
  [self.toolbar setDelegate:self.toolbarDelegate];
  [self.window setToolbar:self.toolbar];
  
  [self.splitView setDelegate:self.splitViewDelegate];
  
  /* Add outlineview */
  const NSRect outlineFrame = [self.outlineView frame];
  [self.outlineViewController.view setFrame:outlineFrame];
  [self.outlineViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [self.splitView replaceSubview:self.outlineView with:[self.outlineViewController view]];
  [self.outlineViewController updateResponderChain];
  
  /* Add inspector view */
  const NSRect inspectorFrame = [self.inspectorView frame];
  [self.inspectorTabViewController.view setFrame:inspectorFrame];
  [self.inspectorTabViewController.view setAutoresizesSubviews:NSViewWidthSizable | NSViewHeightSizable ];
  [self.splitView replaceSubview:self.inspectorView with:[self.inspectorTabViewController view]];
  [self.inspectorTabViewController updateResponderChain];
  
  [self.splitView adjustSubviews];
  [self toggleInspector:nil];
  
  [self _setContentViewController:nil];
}

- (void)_setContentViewController:(MPViewController *)viewController {
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
  [viewController updateResponderChain];
  [self.contentView setNeedsDisplay:YES];
  [self.splitView adjustSubviews];
  /*
   Set focus AFTER having added the view
   */
  [self.window makeFirstResponder:[viewController reconmendedFirstResponder]];
}

- (void)_updateWindowTitle {
  if([MPDatabaseController defaultController].database) {
    NSString *appName = [(MPAppDelegate *)[NSApp delegate] applicationName];
    NSString *openFile = [[MPDatabaseController defaultController].database.file lastPathComponent];
    [self.window setTitle:[NSString stringWithFormat:@"%@ - %@", appName, openFile]];
  }
  else {
    [self.window setTitle:[(MPAppDelegate *)[NSApp delegate] applicationName]];
  }
}

#pragma mark Actions

- (void)toggleInspector:(id)sender {
  NSView *inspectorView = [self.splitView subviews][MPSplitViewInspectorViewIndex];
  const BOOL collapsed = [self.splitView isSubviewCollapsed:inspectorView];
  if(collapsed) {
    if( NO == [self _windowsIsLargeEnoughForInspectorView]) {
      [self _resizeWindowForInspectorView];
    }
    CGFloat splitterPosition = [self.splitView frame].size.width - MPMainWindowSplitViewDelegateMinimumInspectorWidth;
    [self.splitView setPosition:splitterPosition ofDividerAtIndex:MPSplitViewInspectorDividerIndex];
  }
  else {
    CGFloat splitterPosition = [self.splitView frame].size.width;
    [self.splitView setPosition:splitterPosition ofDividerAtIndex:MPSplitViewInspectorDividerIndex];
  }
  [inspectorView setHidden:!collapsed];
}

- (void)performFindPanelAction:(id)sender {
  [self.entryViewController showFilter:sender];
}

- (void)toggleOutlineView:(id)sender {
  
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  SEL menuAction = [menuItem action];
  if(menuAction == @selector(toggleOutlineView:)) {
    NSView *outlineView = [self.splitView subviews][MPSplitViewOutlineViewIndex];
    BOOL outlineIsHidden = [self.splitView isSubviewCollapsed:outlineView];
    NSString *title = outlineIsHidden ? NSLocalizedString(@"SHOW_OUTLINE_VIEW", @"") : NSLocalizedString(@"HIDE_OUTLINE_VIEW", @"Hide the Outline View");
    
    [menuItem setTitle:title];
    return YES;
  }
  if( menuAction == @selector(toggleInspector:) ) {
    NSView *inspectorView = [self.splitView subviews][MPSplitViewInspectorViewIndex];
    BOOL inspectorIsHidden = [self.splitView isSubviewCollapsed:inspectorView];
    NSString *title = inspectorIsHidden ? NSLocalizedString(@"SHOW_INSPECTOR", @"Show the Inspector") : NSLocalizedString(@"HIDE_INSPECTOR", @"Hide the Inspector");
    
    [menuItem setTitle:title];
    return YES;
  }
  return YES;
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
  return [self.toolbarDelegate validateToolbarItem:theItem];
}


- (void)showPasswordInput {
    if(!self.passwordInputController) {
      self.passwordInputController = [[[MPPasswordInputController alloc] init] autorelease];
    }
    [self _setContentViewController:self.passwordInputController];
}

- (void)clearOutlineSelection:(id)sender {
  [self.outlineViewController clearSelection];
}

- (void)editPassword:(id)sender {
  if(!self.passwordEditController) {
    _passwordEditController = [[MPPasswordEditViewController alloc] init];
  }
  [self _setContentViewController:self.passwordEditController];
}

#pragma mark Helper

- (NSSearchField *)locateToolbarSearchField {
  for(NSToolbarItem *toolbarItem in [[self.window toolbar] items]) {
    NSView *view = [toolbarItem view];
    if([view isKindOfClass:[NSSearchField class]]) {
      return (NSSearchField *)view;
    }
  }
  return nil;
}

- (BOOL)_windowsIsLargeEnoughForInspectorView {
  return ( MPMainWindowSplitViewDelegateMinimumInspectorWidth
          < ([self.splitView frame].size.width
             - MPMainWindowSplitViewDelegateMinimumContentWidth
             - MPMainWindowSplitViewDelegateMinimumOutlineWidth
             - 2 * [self.splitView dividerThickness]) );
}

- (void)_resizeWindowForInspectorView {
  NSRect frame = [self.window frame];
  NSView *outlinView = [self.splitView subviews][MPSplitViewOutlineViewIndex];
  NSView *contentView = [self.splitView subviews][MPSplitViewContentViewIndex];
  
  CGFloat outlineWidth = [self.splitView isSubviewCollapsed:outlinView] ? 0 : [outlinView frame].size.width;
  frame.size.width = outlineWidth + [contentView frame].size.width + MPMainWindowSplitViewDelegateMinimumInspectorWidth;
  [self.window setFrame:frame display:YES animate:YES];
}

#pragma mark Notifications
- (void)showEntries {
  if(!self.entryViewController) {
    _entryViewController = [[MPEntryViewController alloc] init];
  }
  [self _setContentViewController:self.entryViewController];
}

@end
