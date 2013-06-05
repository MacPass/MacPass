//
//  MPOutlineViewController.m
//  MacPass
//
//  Created by michael starke on 19.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineViewController.h"
#import "MPOutlineViewDelegate.h"
#import "MPOutlineDataSource.h"
#import "MPDocument.h"
#import "MPAppDelegate.h"
#import "KdbLib.h"

@interface MPOutlineViewController ()

@property (assign) IBOutlet NSOutlineView *outlineView;

@property (retain) MPOutlineDataSource *datasource;
@property (retain) MPOutlineViewDelegate *outlineDelegate;
@property (retain) NSMenu *menu;
@property (retain) NSArray *showConstraints;
@property (retain) NSArray *hideConstraints;


- (void)_didUpdateData:(NSNotification *)notification;
- (NSMenu *)_contextMenu;
- (KdbGroup *)_clickedOrSelectedGroup;

@end

@implementation MPOutlineViewController

- (id)init {
  return [[MPOutlineViewController alloc] initWithNibName:@"OutlineView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _isVisible = YES;
    self.outlineDelegate = [[[MPOutlineViewDelegate alloc] init] autorelease];
    self.datasource = [[[MPOutlineDataSource alloc] init] autorelease];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didUpdateData:)
                                                 name:MPDocumentDidAddGroupNotification
                                               object:[[self windowController] document]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didUpdateData:)
                                                 name:MPDocumentWillDelteGroupNotification
                                               object:[[self windowController] document]];
    
  }
  
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.datasource = nil;
  self.outlineDelegate = nil;
  self.menu = nil;
  [super dealloc];
}

- (void)didLoadView {
  [self.outlineView setDataSource:self.datasource];
  [self.outlineView setDelegate:self.outlineDelegate];
  [self.outlineView setMenu:[self _contextMenu]];
  [self.outlineView setAllowsEmptySelection:YES];
  [self.outlineView setFloatsGroupRows:NO];
  
  NSView *myView = [self view];
  self.showConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[myView(>=100,<=250)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(myView)];

  self.hideConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[myView(==0)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(myView)];
  [[self view] addConstraints:_showConstraints];
  
}

- (void)showOutline {
  [self.outlineView reloadData];
  MPDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
  [self.outlineView expandItem:document.root expandChildren:NO];
}

- (void)clearSelection {
  [self.outlineView deselectAll:nil];
}

- (void)setIsVisible:(BOOL)isVisible {
  if(_isVisible == isVisible) {
    return; // nichts zu tun
  }
  [[self view] removeConstraints:(isVisible ? self.hideConstraints : self.showConstraints)];
  [[self view] addConstraints:(isVisible ? self.showConstraints : self.hideConstraints)];
  _isVisible = isVisible;
}


- (NSMenu *)_contextMenu {
  NSMenu *menu = [[NSMenu alloc] init];
  NSArray *items = [(MPAppDelegate *)[NSApp delegate] contextMenuItemsWithItems:MPContextMenuMinimal];
  for(NSMenuItem *item in items) {
    [menu addItem:item];
  }
  return [menu autorelease];
}

- (void)createGroup:(id)sender {
  KdbGroup *group = [self _clickedOrSelectedGroup];
  MPDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
  if(!group) {
    group = document.root;
  }
  [document createGroup:group];
  [self.outlineView reloadData];
}

- (void)createEntry:(id)sender {
  KdbGroup *group = [self _clickedOrSelectedGroup];
  if(!group.parent) {
    return; // Entries are not allowed in root group
  }
  if(group) {
    MPDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
    [document createEntry:group];
    // Notify the the entry view about changes
  }
}

- (void)deleteEntry:(id)sender {
  KdbGroup *group = [self _clickedOrSelectedGroup];
  if(group) {
    [group.parent removeGroup:group];
    [self.outlineView reloadData];
  }
}

- (KdbGroup *)_clickedOrSelectedGroup {
  NSInteger row = [self.outlineView clickedRow];
  if( row < 0 ) {
    row = [self.outlineView selectedRow];
  }
  return [self.outlineView itemAtRow:row];
}

- (void)_didUpdateData:(NSNotification *)notification {
  [self.outlineView reloadData];
}


@end
