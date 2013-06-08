//
//  MPOutlineViewDelegate.m
//  MacPass
//
//  Created by Michael Starke on 21.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineViewDelegate.h"
#import "MPIconHelper.h"
#import "MPUppercaseStringValueTransformer.h"
#import "HNHBadgedTextFieldCell.h"
#import "KdbLib.h"

NSString *const MPOutlineViewDidChangeGroupSelection = @"com.macpass.MPOutlineViewDidChangeGroupSelection";

NSString *const _MPOutlineViewDataViewIdentifier = @"DataCell";
NSString *const _MPOutlinveViewHeaderViewIdentifier = @"HeaderCell";

@interface MPOutlineViewDelegate ()

@property (assign) KdbGroup *selectedGroup;

@end

@implementation MPOutlineViewDelegate

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
  NSOutlineView *outlineView = [notification object];
  //KdbGroup *selectedGroup = [outlineView itemAtRow:[outlineView selectedRow]];
  NSTreeNode *treeNode = [outlineView itemAtRow:[outlineView selectedRow]];
  KdbGroup *selectedGroup = [treeNode representedObject];
  self.selectedGroup = selectedGroup;
  [[NSNotificationCenter defaultCenter] postNotificationName:MPOutlineViewDidChangeGroupSelection object:self userInfo:nil];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
  return YES;
//  KdbGroup *group = [item representedObject];
//  return (nil != group.parent);
}

@end
