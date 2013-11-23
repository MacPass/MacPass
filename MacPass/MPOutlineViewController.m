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
#import "MPDocumentWindowController.h"
#import "MPContextMenuHelper.h"
#import "MPConstants.h"
#import "MPActionHelper.h"
#import "MPIconHelper.h"
#import "MPUppercaseStringValueTransformer.h"
#import "MPNotifications.h"
#import "MPOutlineContextMenuDelegate.h"

#import "KPKTree.h"
#import "KPKGroup.h"
#import "KPKNode+IconImage.h"
#import "KPKMetaData.h"
#import "KPKUTIs.h"

#import "HNHGradientView.h"

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

- (id)init {
  return [[MPOutlineViewController alloc] initWithNibName:@"OutlineView" bundle:nil];
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


- (void)didLoadView {
  [_outlineView setDelegate:self];
  [_outlineView setMenu:[self _contextMenu]];
  [_outlineView setAllowsEmptySelection:YES];
  [_outlineView setFloatsGroupRows:NO];
  [_outlineView registerForDraggedTypes:@[ KPKGroupUTI, KPKEntryUTI ]];
  [_outlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
  [_bottomBar setBorderType:HNHBorderTop];
  [_addGroupButton setAction:[MPActionHelper actionOfType:MPActionAddGroup]];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didBecomeFirstResponder:)
                                               name:MPDidActivateViewNotification
                                             object:_outlineView];
}

#pragma makr Outline handling

- (void)showOutline {
  if(!_bindingEstablished) {
    MPDocument *document = [[self windowController] document];
    [_treeController setChildrenKeyPath:@"groups"];
    [_treeController bind:NSContentBinding toObject:document withKeyPath:@"tree" options:nil];
    [_outlineView bind:NSContentBinding toObject:_treeController withKeyPath:@"arrangedObjects" options:nil];
    [self bind:@"databaseNameWrapper" toObject:document.tree.metaData withKeyPath:@"databaseName" options:nil];
    [_outlineView setDataSource:self.datasource];
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
  for(NSTreeNode *child in [node childNodes]) {
    [self _expandItems:child];
  }
}

#pragma mark Custom Setter/Getter
- (void)setDatabaseNameWrapper:(NSString *)databaseNameWrapper {
  if(![_databaseNameWrapper isEqualToString:databaseNameWrapper]) {
    if([databaseNameWrapper length] == 0) {
      _databaseNameWrapper = NSLocalizedString(@"DATABASE", "Default name database");
    }
    else {
      _databaseNameWrapper= [databaseNameWrapper copy];
    }
  }
}

#pragma mark Notifications
- (void)setupNotifications:(MPDocumentWindowController *)windowController {
  // Nothing to do anymore
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

- (void)createGroup:(id)sender {
  KPKGroup *group = [self _clickedOrSelectedGroup];
  MPDocument *document = [[self windowController] document];
  if(!group) {
    group = document.root;
  }
  [document createGroup:group];
}

- (void)createEntry:(id)sender {
  MPDocument *document = [[self windowController] document];
  [document createEntry:[self _clickedOrSelectedGroup]];
}

- (void)deleteNode:(id)sender {
  [[[self windowController] document] deleteGroup:[self _clickedOrSelectedGroup]];
}

#pragma mark NSOutlineViewDelegate
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
  NSTableCellView *view;
  if( [self _itemIsRootNode:item] ) {
    //NSDictionary *options = @{ NSValueTransformerBindingOption : [NSValueTransformer valueTransformerForName:MPUppsercaseStringValueTransformerName] };
    view = [outlineView makeViewWithIdentifier:_MPOutlinveViewHeaderViewIdentifier owner:self];
    [view.textField bind:NSValueBinding toObject:self  withKeyPath:@"databaseNameWrapper" options:nil];
  }
  else {
    KPKGroup *group = [item representedObject];
    view = [outlineView makeViewWithIdentifier:_MPOutlineViewDataViewIdentifier owner:self];
    
    [view.imageView setImage:group.iconImage];
    [view.textField bind:NSValueBinding toObject:group withKeyPath:@"name" options:nil];
    [view.textField bind:@"count" toObject:group withKeyPath:@"entries.@count" options:nil];
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
  id item = userInfo[@"NSObject"];
  id representedObject = [item representedObject];
  if([representedObject isKindOfClass:[KPKGroup class]]) {
    KPKGroup *group = (KPKGroup *)representedObject;
    group.isExpanded = YES;
  }
}
- (void)outlineViewItemDidCollapse:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  id item = userInfo[@"NSObject"];
  id representedObject = [item representedObject];
  if([representedObject isKindOfClass:[KPKGroup class]]) {
    KPKGroup *group = (KPKGroup *)representedObject;
    group.isExpanded = NO;
  }
}

#pragma mark Validation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  MPDocument *document = [[self windowController] document];
  if(![document validateUserInterfaceItem:menuItem]) {
    return NO;
  }
  id selected = [self _clickedOrSelectedGroup];
  if(!selected) { return NO; }
  if(selected == document.trash) { return NO; }
  return ![document isItemTrashed:selected];
}

#pragma mark -
#pragma mark Private

- (KPKGroup *)_clickedOrSelectedGroup {
  NSInteger row = [self.outlineView clickedRow];
  if( row < 0 ) {
    row = [self.outlineView selectedRow];
  }
  return [[self.outlineView itemAtRow:row] representedObject];
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
