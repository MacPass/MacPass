//
//  MPOutlineViewDelegate.m
//  MacPass
//
//  Created by Michael Starke on 21.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineViewDelegate.h"

@implementation MPOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
  NSTableCellView *view = [outlineView makeViewWithIdentifier:@"OutlineCell" owner:self];
  [view.imageView setImage:[NSImage imageNamed:NSImageNameFolder]];
  [view.textField setStringValue:@"Test"];
  return view;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
  if(item == nil) {
    return YES;
  }
  return NO;
}

@end
