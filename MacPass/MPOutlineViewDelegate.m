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
  NSTableCellView *view = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
  [view.imageView setImage:[NSImage imageNamed:NSImageNameFolder]];
  if([item isKindOfClass:[KdbGroup class]]) {
    KdbGroup *group = item;
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

@end
