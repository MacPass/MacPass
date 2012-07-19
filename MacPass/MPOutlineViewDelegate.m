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
  NSView *view = [outlineView makeViewWithIdentifier:@"OutlineViewCell" owner:self];
  return view;
}

@end
