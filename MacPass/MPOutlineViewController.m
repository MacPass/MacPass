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

#import "KPKEntry.h"
#import "KPKGroup.h"
#import "KPKMetaData.h"
#import "KPKNode.h"
#import "KPKNode+IconImage.h"
#import "KPKTimeInfo.h"
#import "KPKTree.h"
#import "KPKUTIs.h"

#import "HNHGradientView.h"

#define EXPIRED_GROUP_REFRESH_SECONDS 60

NSString *const MPOutlineViewDidChangeGroupSelection = @"com.macpass.MPOutlineViewDidChangeGroupSelection";

NSString *const _MPOutlineViewDataViewIdentifier = @"DataCell";
NSString *const _MPOutlinveViewHeaderViewIdentifier = @"HeaderCell";

@interface MPOutlineViewController () {
  BOOL _bindingEstablished;
  MPOutlineContextMenuDelegate *_menuDelegate;
  
}
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSButton *addGroupButton;

@property (strong) NSTreeController *treeController;
@property (strong) MPOutlineDataSource *datasource;
@property (strong) NSMenu *menu;

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
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self.outlineView setDelegate:nil];
}

- (void)didLoadView {
  [self.outlineView setDelegate:self];
  [self.outlineView setMenu:[self _contextMenu]];
  [self.outlineView setAllowsEmptySelection:YES];
  [self.outlineView setFloatsGroupRows:NO];
  [self.outlineView registerForDraggedTypes:@[ KPKGroupUTI, KPKEntryUTI ]];
  [self.outlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
  [self.outlineView setDoubleAction:@selector(_doubleClickedGroup:)];
  [self.bottomBar setBorderType:HNHBorderTop|HNHBorderHighlight];
  [self.addGroupButton setAction:[MPActionHelper actionOfType:MPActionAddGroup]];
  
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
    MPDocument *document = [[self windowController] document];
    [_treeController setChildrenKeyPath:NSStringFromSelector(@selector(groups))];
    [_treeController bind:NSContentBinding toObject:document withKeyPath:NSStringFromSelector(@selector(tree)) options:nil];
    [_outlineView bind:NSContentBinding toObject:_treeController withKeyPath:NSStringFromSelector(@selector(arrangedObjects)) options:nil];
    [self bind:NSStringFromSelector(@selector(databaseNameWrapper)) toObject:document.tree.metaData withKeyPath:NSStringFromSelector(@selector(databaseName)) options:nil];
    [_outlineView setDataSource:self.datasource];
    _bindingEstablished = YES;
    [self _updateExpirationDisplay];
    
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
  for(NSTreeNode *child in [node childNodes]) {
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
- (KPKGroup *)currentTargetGroup {
  NSInteger row = [self.outlineView clickedRow];
  if( row < 0 ) {
    row = [self.outlineView selectedRow];
  }
  return [[self.outlineView itemAtRow:row] representedObject];
}

- (KPKNode *)currentTargetNode {
  KPKGroup *group = [self currentTargetGroup];
  if(group) {
    return group;
  }
  MPDocument *document = [[self windowController] document];
  return document.selectedItem;
}

#pragma mark Notifications
- (void)regsiterNotificationsForDocument:(MPDocument *)document {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didAddGroup:) name:MPDocumentDidAddGroupNotification object:document];
}

- (void)clearSelection {
  [_outlineView deselectAll:nil];
  [self outlineViewSelectionDidChange:nil];
}

- (void)_didBecomeFirstResponder:(NSNotification *)notification {
  if( [notification object] != _outlineView ) {
    return; // Nothing we need to worry about
  }
  MPDocument *document = [[self windowController] document];
  document.selectedItem = document.selectedGroup;
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
  NSPoint mouseLocation = [[self.outlineView window] mouseLocationOutsideOfEventStream];
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
    KPKGroup *group = [item representedObject];
    view = [outlineView makeViewWithIdentifier:_MPOutlineViewDataViewIdentifier owner:self];
    
    [[view imageView] bind:NSValueBinding toObject:group withKeyPath:NSStringFromSelector(@selector(iconImage)) options:nil];
    [[view textField] bind:NSValueBinding toObject:group withKeyPath:NSStringFromSelector(@selector(name)) options:nil];
    NSString *entriesCountKeyPath = [[NSString alloc] initWithFormat:@"%@.%@", NSStringFromSelector(@selector(entries)), @"@count"];
    [[view textField] bind:NSStringFromSelector(@selector(count)) toObject:group withKeyPath:entriesCountKeyPath options:nil];
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
  NSTreeNode *treeNode = [_outlineView itemAtRow:[_outlineView selectedRow]];
  KPKGroup *selectedGroup = [treeNode representedObject];
  MPDocument *document = [[self windowController] document];
  document.selectedGroup = selectedGroup;
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
    [self outlineViewSelectionDidChange:nil];
  }
}

#pragma mark Validation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  MPDocument *document = [[self windowController] document];
  if(![document validateUserInterfaceItem:menuItem]) {
    return NO;
  }
  id selected = [[self currentTargetNode] asGroup];
  if(!selected) {
    return NO;
  }
  if(selected == document.trash) {
    return NO;
  }
  return ![document isItemTrashed:selected];
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

- (void)_updateExpirationDisplay {
  MPDocument *document = [[self windowController] document];
  [document.root.timeInfo isExpired];
  [[document.tree allGroups] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [[obj timeInfo] isExpired];
  }];
  [self performSelector:@selector(_updateExpirationDisplay) withObject:nil afterDelay:EXPIRED_GROUP_REFRESH_SECONDS];
}

@end
