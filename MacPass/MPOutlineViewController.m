//
//  MPOutlineViewController.m
//  MacPass
//
//  Created by michael starke on 19.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineViewController.h"
#import "MPOutlineDataSource.h"
#import "MPDocument.h"
#import "MPAppDelegate.h"
#import "MPContextMenuHelper.h"
#import "MPConstants.h"
#import "MPActionHelper.h"
#import "MPIconHelper.h"
#import "MPUppercaseStringValueTransformer.h"

#import "KdbLib.h"
#import "KdbGroup+Undo.h"

#import "HNHGradientView.h"

NSString *const MPOutlineViewDidChangeGroupSelection = @"com.macpass.MPOutlineViewDidChangeGroupSelection";

NSString *const _MPOutlineViewDataViewIdentifier = @"DataCell";
NSString *const _MPOutlinveViewHeaderViewIdentifier = @"HeaderCell";

@interface MPOutlineViewController () {
  BOOL _bindingEstablished;
}
@property (assign) IBOutlet NSOutlineView *outlineView;
@property (assign) IBOutlet NSButton *addGroupButton;
@property (assign) KdbGroup *selectedGroup;

@property (retain) NSTreeController *treeController;
@property (retain) MPOutlineDataSource *datasource;
@property (retain) NSMenu *menu;

@end

@implementation MPOutlineViewController

- (id)init {
  return [[MPOutlineViewController alloc] initWithNibName:@"OutlineView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _treeController = [[NSTreeController alloc] init];
    _bindingEstablished = NO;
    _datasource = [[MPOutlineDataSource alloc] init];
  }
  
  return self;
}

- (void)dealloc {
  [_treeController release];
  [_datasource release];
  [_menu release];
  [super dealloc];
}

- (void)didLoadView {
  [_outlineView setDelegate:self];
  [_outlineView setMenu:[self _contextMenu]];
  [_outlineView setAllowsEmptySelection:YES];
  [_outlineView setFloatsGroupRows:NO];
  [_outlineView registerForDraggedTypes:@[ MPPasteBoardType ]];
  [_outlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
  [_bottomBar setBorderType:HNHBorderTop];
  [_addGroupButton setAction:[MPActionHelper actionOfType:MPActionAddGroup]];
}

- (void)showOutline {
  if(!_bindingEstablished) {
    MPDocument *document = [[self windowController] document];
    [_treeController setChildrenKeyPath:@"groups"];
    [_treeController bind:NSContentBinding toObject:document withKeyPath:@"root" options:nil];
    [_outlineView bind:NSContentBinding toObject:_treeController withKeyPath:@"arrangedObjects" options:nil];
    [_outlineView setDataSource:self.datasource];
    _bindingEstablished = YES;
  }
  NSTreeNode *node = [_outlineView itemAtRow:0];
  [_outlineView expandItem:node expandChildren:NO];
}

#pragma makr Notifications
- (void)setupNotifications:(MPDocumentWindowController *)windowController {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didCreateGroup:) name:MPDocumentDidAddGroupNotification object:[windowController document]];
}

- (void)clearSelection {
  [_outlineView deselectAll:nil];
  [self outlineViewSelectionDidChange:nil];
}

- (void)_didCreateGroup:(NSNotification *)notification {
  NSInteger selectedRow = [_outlineView selectedRow];
  NSIndexSet *indexSet;
  if( selectedRow == -1) {
    MPDocument *document = [[self windowController] document];
    indexSet = [NSIndexSet indexSetWithIndex:[document.root.groups count]];
    //TODO: Find out why selection is not set (treeUpdate?)
  }
  else {
    id item = [_outlineView itemAtRow:selectedRow];
    [_outlineView expandItem:item];
    indexSet = [NSIndexSet indexSetWithIndex:selectedRow + 1];
  }
  [_outlineView selectRowIndexes:indexSet byExtendingSelection:NO];
}

#pragma mark -
#pragma mark Actions

- (void)createGroup:(id)sender {
  KdbGroup *group = [self _clickedOrSelectedGroup];
  MPDocument *document = [[self windowController] document];
  if(!group) {
    group = document.root;
  }
  BOOL isFistGroup = [document.root.groups count] == 0;
  [document createGroup:group];
  /*
   TODO: Find out if a lower hierachy node was the first child
   and auto-expand that item too
   */
  if(isFistGroup) {
    NSTreeNode *node = [_outlineView itemAtRow:0];
    [_outlineView expandItem:node expandChildren:NO];
  }
}

- (void)createEntry:(id)sender {
  KdbGroup *group = [self _clickedOrSelectedGroup];
  if(!group.parent) {
    return; // Entries are not allowed in root group
  }
  if(group) {
    MPDocument *document = [[self windowController] document];
    [document createEntry:group];
  }
}

- (void)deleteNode:(id)sender {
  KdbGroup *group = [self _clickedOrSelectedGroup];
  if(group && group.parent) {
    [[[self windowController] document] group:group.parent removeGroup:group];
  }
}

#pragma mark NSOutlineViewDelegate
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
  NSTreeNode *treeNode = item;
  KdbGroup *group = [treeNode representedObject];
  //KdbGroup *group = item;
  NSTableCellView *view;
  if(![group parent]) {
    NSDictionary *options = @{ NSValueTransformerBindingOption : [NSValueTransformer valueTransformerForName:MPUppsercaseStringValueTransformerName] };
    view = [outlineView makeViewWithIdentifier:_MPOutlinveViewHeaderViewIdentifier owner:self];
    [view.textField bind:NSValueBinding toObject:group withKeyPath:@"name" options:options];
  }
  else {
    view = [outlineView makeViewWithIdentifier:_MPOutlineViewDataViewIdentifier owner:self];
    NSImage *icon = [MPIconHelper icon:(MPIconType)[group image]];
    [view.imageView setImage:icon];
    [view.textField bind:NSValueBinding toObject:group withKeyPath:@"name" options:nil];
    [view.textField bind:@"count" toObject:group withKeyPath:@"entries.@count" options:nil];
  }
  
  return view;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
  NSTreeNode *treeNode = item;
  KdbGroup *group = [treeNode representedObject];
  //KdbGroup *group = item;
  if(!group.parent) {
    return YES;
  }
  return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
  NSTreeNode *treeNode = item;
  KdbGroup *group = [treeNode representedObject];
  //KdbGroup *group = item;
  return (nil != [group parent]);
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
  NSTreeNode *treeNode = [_outlineView itemAtRow:[_outlineView selectedRow]];
  KdbGroup *selectedGroup = [treeNode representedObject];
  self.selectedGroup = selectedGroup;
  [[NSNotificationCenter defaultCenter] postNotificationName:MPOutlineViewDidChangeGroupSelection object:self userInfo:nil];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
  return YES;
  //  KdbGroup *group = [item representedObject];
  //  return (nil != group.parent);
}

#pragma mark -
#pragma mark Private

- (KdbGroup *)_clickedOrSelectedGroup {
  NSInteger row = [self.outlineView clickedRow];
  if( row < 0 ) {
    row = [self.outlineView selectedRow];
  }
  return [[self.outlineView itemAtRow:row] representedObject];
}

- (NSMenu *)_contextMenu {
  NSMenu *menu = [[NSMenu alloc] init];
  NSArray *items = [MPContextMenuHelper contextMenuItemsWithItems:MPContextMenuMinimal];
  for(NSMenuItem *item in items) {
    [menu addItem:item];
  }
  return [menu autorelease];
}

@end
