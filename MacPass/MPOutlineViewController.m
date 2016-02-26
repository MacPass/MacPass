//
//  MPOutlineViewController.m
//  MacPass
//
//  Created by michael starke on 19.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineViewController.h"
#import "MPActionHelper.h"
#import "MPConstants.h"
#import "MPContextMenuHelper.h"
#import "MPDocument.h"
#import "MPDocumentWindowController.h"
#import "MPIconHelper.h"
#import "MPNotifications.h"
#import "MPOutlineContextMenuDelegate.h"
#import "MPOutlineDataSource.h"

#import "KeePassKit/KeePassKit.h"
#import "KPKNode+IconImage.h"

#import "HNHUi/HNHUi.h"

#define EXPIRED_GROUP_REFRESH_SECONDS 60

NSString *const MPOutlineViewDidChangeGroupSelection = @"com.macpass.MPOutlineViewDidChangeGroupSelection";

NSString *const _MPOutlineViewDataViewIdentifier = @"DataCell";
NSString *const _MPOutlinveViewHeaderViewIdentifier = @"HeaderCell";

@interface MPOutlineViewController () {
  BOOL _bindingEstablished;
  MPOutlineContextMenuDelegate *_menuDelegate;
  
}
@property (weak) IBOutlet NSOutlineView *outlineView;

@property (strong) NSTreeController *treeController;
@property (strong) MPOutlineDataSource *datasource;

@property (copy, nonatomic) NSString *databaseNameWrapper;

@end

@implementation MPOutlineViewController

- (NSString *)nibName {
  return @"OutlineView";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _treeController = [[NSTreeController alloc] init];
    _bindingEstablished = NO;
    _datasource = [[MPOutlineDataSource alloc] init];
    _databaseNameWrapper = NSLocalizedString(@"NEW_DATABASE", "Name for a newly created Database");
    _menuDelegate = [[MPOutlineContextMenuDelegate alloc] init];
    _menuDelegate.viewController = self;
  }
  
  return self;
}

- (void)dealloc {
  [self.outlineView unbind:NSContentBinding];
  [self.treeController unbind:NSContentBinding];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self.outlineView setDelegate:nil];
}

- (void)didLoadView {
  self.outlineView.menu = [self _contextMenu];
  self.outlineView.allowsEmptySelection = YES;
  self.outlineView.floatsGroupRows = NO;
  self.outlineView.doubleAction = @selector(_doubleClickedGroup:);
  self.outlineView.allowsMultipleSelection = YES;
  [self.outlineView setDelegate:self];
  [self.outlineView registerForDraggedTypes:@[ KPKGroupUTI, KPKEntryUTI ]];
  [self.outlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didBecomeFirstResponder:)
                                               name:MPDidActivateViewNotification
                                             object:self.outlineView];
  
}

- (NSResponder *)reconmendedFirstResponder {
  return self.outlineView;
}

#pragma mark Outline handling

- (void)showOutline {
  if(!_bindingEstablished) {
    MPDocument *document = self.windowController.document;
    self.treeController.childrenKeyPath = NSStringFromSelector(@selector(groups));
    [self.treeController bind:NSContentBinding toObject:document withKeyPath:NSStringFromSelector(@selector(tree)) options:nil];
    [self.outlineView bind:NSContentBinding toObject:self.treeController withKeyPath:NSStringFromSelector(@selector(arrangedObjects)) options:nil];
    [self.outlineView bind:NSSelectionIndexPathsBinding toObject:self.treeController withKeyPath:NSStringFromSelector(@selector(selectionIndexPaths)) options:nil];
    [self bind:NSStringFromSelector(@selector(databaseNameWrapper)) toObject:document.tree.metaData withKeyPath:NSStringFromSelector(@selector(databaseName)) options:nil];
    [self.outlineView setDataSource:self.datasource];
    _bindingEstablished = YES;
  }
  NSTreeNode *node = [_outlineView itemAtRow:0];
  [self _expandItems:node];
}

- (void)_expandItems:(NSTreeNode *)node {
  id nodeItem = [node representedObject];
  if([nodeItem isKindOfClass:[KPKTree class]]) {
    [self.outlineView expandItem:node expandChildren:NO];
  }
  else if([nodeItem respondsToSelector:@selector(isExpanded)]) {
    if([nodeItem isExpanded]) {
      [self.outlineView expandItem:node];
    }
    else {
      [self.outlineView collapseItem:node];
    }
  }
  for(NSTreeNode *child in node.childNodes) {
    [self _expandItems:child];
  }
}

#pragma mark Custom Setter/Getter
- (void)setDatabaseNameWrapper:(NSString *)databaseNameWrapper {
  if(![_databaseNameWrapper isEqualToString:databaseNameWrapper]) {
    _databaseNameWrapper = (databaseNameWrapper.length == 0) ? NSLocalizedString(@"DATABASE", "Default name database") : [databaseNameWrapper copy];
  }
}

#pragma mark MPTargetNodeResolving
- (NSArray<KPKGroup *> *)currentTargetGroups {
  //  NSInteger row = self.outlineView.clickedRow;
//  if( row > -1 ) {
//      return @[ [[self.outlineView itemAtRow:row] representedObject] ];
//  }
  return self.treeController.selectedObjects;
}

- (NSArray<KPKNode *> *)currentTargetNodes {
  NSArray *groups = [self currentTargetGroups];
  if(groups.count > 0) {
    return groups;
  }
  MPDocument *document = self.windowController.document;
  return document.selectedNodes;
}

#pragma mark Notifications
- (void)regsiterNotificationsForDocument:(MPDocument *)document {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didAddGroup:) name:MPDocumentDidAddGroupNotification object:document];
}

- (void)clearSelection {
  [_outlineView deselectAll:nil];
  NSNotification *notification = [NSNotification notificationWithName:NSOutlineViewSelectionDidChangeNotification object:_outlineView];
  [self outlineViewSelectionDidChange:notification];
}

- (void)_didBecomeFirstResponder:(NSNotification *)notification {
  if( [notification object] != _outlineView ) {
    return; // Nothing we need to worry about
  }
  MPDocument *document = [[self windowController] document];
  document.selectedGroups = self.treeController.selectedObjects;
  //document.selectedItem = document.selectedGroup;
}

# pragma mark MPDocument Notifications
- (void)_didAddGroup:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  KPKGroup *group = userInfo[MPDocumentGroupKey];
  NSIndexPath *groupIndexPath = [group indexPath];
  NSTreeNode *groupNode = [[self.treeController arrangedObjects] descendantNodeAtIndexPath:groupIndexPath];
  [self.outlineView expandItem:groupNode.parentNode];
  NSInteger groupRow = [self.outlineView rowForItem:groupNode];
  [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:groupRow] byExtendingSelection:NO];
  [self.outlineView scrollRowToVisible:groupRow];
}

- (id)itemUnderMouse {
  NSPoint mouseLocation = [self.outlineView.window mouseLocationOutsideOfEventStream];
  NSPoint localPoint = [self.outlineView convertPoint:mouseLocation fromView:[[self.outlineView window] contentView]];
  NSInteger row = [self.outlineView rowAtPoint:localPoint];
  if(row == -1) {
    return nil; // No row was hit
  }
  return [[self.outlineView itemAtRow:row] representedObject];
}

#pragma mark -
#pragma mark Actions

- (void)_doubleClickedGroup:(id)sender {
  [(MPDocumentWindowController *)self.windowController showInspector:sender];
}

#pragma mark NSOutlineViewDelegate
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
  NSTableCellView *view;
  if( [self _itemIsRootNode:item] ) {
    view = [outlineView makeViewWithIdentifier:_MPOutlinveViewHeaderViewIdentifier owner:self];
    [view.textField bind:NSValueBinding toObject:self  withKeyPath:NSStringFromSelector(@selector(databaseNameWrapper)) options:nil];
  }
  else {
    view = [outlineView makeViewWithIdentifier:_MPOutlineViewDataViewIdentifier owner:self];
    
    NSString *iconImageKeyPath = [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(iconImage))];
    NSString *titleKeyPath = [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(title))];
    [[view imageView] bind:NSValueBinding toObject:item withKeyPath:iconImageKeyPath options:nil];
    [[view textField] bind:NSValueBinding toObject:item withKeyPath:titleKeyPath options:nil];
    
    
    NSString *entriesCountKeyPath = [[NSString alloc] initWithFormat:@"%@.%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(entries)), @"@count"];
    [[view textField] bind:NSStringFromSelector(@selector(count)) toObject:item withKeyPath:entriesCountKeyPath options:nil];
  }
  
  return view;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
  return [self _itemIsRootNode:item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
  return ![self _itemIsRootNode:item];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
  MPDocument *document = self.windowController.document;
  if(![self.treeController.selectedObjects.firstObject isKindOfClass:[KPKTree class]]) {
    document.selectedGroups = self.treeController.selectedObjects;
  }
  else {
    document.selectedGroups = nil;
  }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
  return ![self _itemIsRootNode:item];
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  id item = userInfo[NSStringFromClass([NSObject class])];
  id representedObject = [item representedObject];
  if([representedObject isKindOfClass:[KPKGroup class]]) {
    KPKGroup *group = (KPKGroup *)representedObject;
    group.isExpanded = YES;
  }
}
- (void)outlineViewItemDidCollapse:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  id item = userInfo[NSStringFromClass([NSObject class])];
  id representedObject = [item representedObject];
  if([representedObject isKindOfClass:[KPKGroup class]]) {
    KPKGroup *group = (KPKGroup *)representedObject;
    group.isExpanded = NO;
  }
}

- (void)outlineView:(NSOutlineView *)outlineView didRemoveRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
  /* Deletion of an item */
  if(row == -1) {
    NSNotification *notification = [NSNotification notificationWithName:NSOutlineViewSelectionDidChangeNotification object:outlineView];
    [self outlineViewSelectionDidChange:notification];
  }
}

#pragma mark Validation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  MPDocument *document = [[self windowController] document];
  if(![document validateUserInterfaceItem:menuItem]) {
    return NO;
  }
  KPKGroup *group = [self currentTargetNodes].firstObject.asGroup;
  return group.isTrash && group.isTrashed;
}

- (NSMenu *)_contextMenu {
  NSMenu *menu = [[NSMenu alloc] init];
  [menu setDelegate:_menuDelegate];
  return menu;
}

- (BOOL)_itemIsRootNode:(id)item {
  id node = [item representedObject];
  return [node isKindOfClass:[KPKTree class]];
}

@end
