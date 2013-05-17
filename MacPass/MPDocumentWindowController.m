//
//  MPMainWindowController.m
//  MacPass
//
//  Created by Michael Starke on 24.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocumentWindowController.h"
#import "MPDocument.h"
#import "MPPasswordInputController.h"
#import "MPEntryViewController.h"
#import "MPPasswordEditViewController.h"
#import "MPToolbarDelegate.h"
#import "MPOutlineViewController.h"
#import "MPMainWindowSplitViewDelegate.h"
#import "MPInspectorTabViewController.h"
#import "MPAppDelegate.h"

@interface MPDocumentWindowController () {
  @private
  BOOL _needsDecryption;
}

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
- (void)_setOutlineVisible:(BOOL)isVisible;


@end

@implementation MPDocumentWindowController

-(id)init {
  self = [super initWithWindowNibName:@"MainWindow" owner:self];
  if( self ) {
    _needsDecryption = NO;
    _toolbarDelegate = [[MPToolbarDelegate alloc] init];
    _outlineViewController = [[MPOutlineViewController alloc] init];
    _inspectorTabViewController = [[MPInspectorTabViewController alloc] init];
    _passwordEditController = [[MPPasswordEditViewController alloc] init];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
  
  [self _setOutlineVisible:NO];
  MPDocument *document = [self document];
  if(!document.isDecrypted) {
      [self showPasswordInput];
  }
  else {
    [self editPassword:nil];
  }
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

- (void)_setOutlineVisible:(BOOL)isVisible {
  self.outlineViewController.isVisible = isVisible;
}

#pragma mark Actions

- (void)toggleInspector:(id)sender {
  if(self.inspectorTabViewController) {
    [self.inspectorTabViewController toggleVisible];
  }
}

- (void)performFindPanelAction:(id)sender {
  [self.entryViewController showFilter:sender];
}



- (void)toggleOutlineView:(id)sender {
  [self _setOutlineVisible:!self.outlineViewController.isVisible];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  SEL menuAction = [menuItem action];
  if(menuAction == @selector(main:)) {
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

#pragma mark Notifications
- (void)showEntries {
  if(!self.entryViewController) {
    _entryViewController = [[MPEntryViewController alloc] init];
  }
  [self _setContentViewController:self.entryViewController];
  [self.outlineViewController showOutline];
  [self _setOutlineVisible:YES];
}

@end
