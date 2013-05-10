//
//  MPOutlineViewDelegate.m
//  MacPass
//
//  Created by Michael Starke on 21.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineViewDelegate.h"
#import "MPIconHelper.h"
#import "KdbLib.h"

NSString *const MPOutlineViewDidChangeGroupSelection = @"com.macpass.MPOutlineViewDidChangeGroupSelection";

NSString *const _MPOutlineViewDataViewIdentifier = @"DataCell";
NSString *const _MPOutlinveViewHeaderViewIdentifier = @"HeaderCell";

@interface MPOutlineViewDelegate ()

@property (assign) KdbGroup *selectedGroup;

@end

@implementation MPOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
  KdbGroup *group = item;
  NSTableCellView *view;
  if(![group parent]) {
    view = [outlineView makeViewWithIdentifier:_MPOutlinveViewHeaderViewIdentifier owner:self];
    [view.textField setStringValue:[group name]];
  }
  else {
    view = [outlineView makeViewWithIdentifier:_MPOutlineViewDataViewIdentifier owner:self];
    NSImage *icon = [MPIconHelper icon:(MPIconType)[group image]];
    [view.imageView setImage:icon];
    [view.textField setStringValue:[group name]];

  }
  
  return view;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
  if(item == nil) {
    return YES;
  }
  return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
  KdbGroup *group = item;
  return (nil != [group parent]);
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
  NSOutlineView *outlineView = [notification object];
  KdbGroup *selectedGroup = [outlineView itemAtRow:[outlineView selectedRow]];
  self.selectedGroup = selectedGroup;
  [[NSNotificationCenter defaultCenter] postNotificationName:MPOutlineViewDidChangeGroupSelection object:self userInfo:nil];
}

@end
