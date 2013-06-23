//
//  MPOverlayView.m
//  MacPass
//
//  Created by Michael Starke on 03.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPOverlayView.h"

@implementation MPOverlayView

- (void)drawRect:(NSRect)dirtyRect {
  [[NSGraphicsContext currentContext] saveGraphicsState];
  [[NSColor clearColor] set];
  NSRectFill([self bounds]);
  NSColor *backgroundColor = [NSColor colorWithCalibratedWhite:0 alpha:0.7];
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:10 yRadius:10];
  [backgroundColor set];
  [path fill];
  [[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (BOOL)isOpaque {
  return NO;
}

@end
