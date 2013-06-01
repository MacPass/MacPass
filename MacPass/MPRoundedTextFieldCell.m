//
//  MPRoundedTextFieldCell.m
//  MacPass
//
//  Created by Michael Starke on 01.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPRoundedTextFieldCell.h"

#define CORNER_RADIUS 10.0

@implementation MPRoundedTextFieldCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:CORNER_RADIUS yRadius:CORNER_RADIUS];
  [[NSColor clearColor] set];
  NSRectFill(cellFrame);
  [[NSColor blackColor] setStroke];
  [[NSColor whiteColor] setFill];
  [path fill];
  [path stroke];
  
  //[super drawWithFrame:cellFrame inView:controlView];
}

@end
