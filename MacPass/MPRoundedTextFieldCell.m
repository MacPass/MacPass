//
//  MPRoundedTextFieldCell.m
//  MacPass
//
//  Created by Michael Starke on 01.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPRoundedTextFieldCell.h"

#define CORNER_RADIUS 3.0

@implementation MPRoundedTextFieldCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
  NSRect pathRect = NSInsetRect(cellFrame, 0.5, 0.5);
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:pathRect xRadius:CORNER_RADIUS yRadius:CORNER_RADIUS];
  [([self isEnabled] ? [NSColor colorWithCalibratedWhite:0.55 alpha:1] : [NSColor colorWithCalibratedWhite:0.75 alpha:1]) setStroke];
  [[NSColor whiteColor] setFill];
  [path fill];
  
  [NSGraphicsContext saveGraphicsState];
  NSShadow *shadow = [[NSShadow alloc] init];
  [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1]];
  [shadow setShadowOffset:NSMakeSize(0, -1)];
  [shadow setShadowBlurRadius:2];
  [shadow set];
  [path setClip];
  [path stroke];
  [shadow release];

  [NSGraphicsContext restoreGraphicsState];
  [path stroke];
  //[shadow release];
  [super drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawFocusRingMaskWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
  NSLog(@"drawFocusRing");
  //NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:CORNER_RADIUS yRadius:CORNER_RADIUS];
  //[path stroke];
  [super drawFocusRingMaskWithFrame:cellFrame inView:controlView];
}

- (NSRect)focusRingMaskBoundsForFrame:(NSRect)cellFrame inView:(NSView *)controlView {
  return [controlView bounds];
}



@end
