//
//  MPOutlineViewDelegate.m
//  MacPass
//
//  Created by Michael Starke on 21.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineViewDelegate.h"
#import "KdbLib.h"

@implementation MPOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
  KdbGroup *group = item;
  NSTableCellView *view;
  if(![group parent]) {
    view = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
    [view.textField setStringValue:[group name]];
  }
  else {
    view = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
    [view.imageView setImage:[NSImage imageNamed:NSImageNameFolder]];
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

@end
