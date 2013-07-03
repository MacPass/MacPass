//
//  MPShadowBox.m
//  MacPass
//
//  Created by Michael Starke on 07.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#define ELIPSIS_OFFSET 0
#define ELIPSIS_HEIGHT 20
#define SHADOW_OFFSET 10

#import "MPShadowBox.h"

@implementation MPShadowBox

- (id)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if(self) {
    _shadowDisplay = MPShadowTopAndBottom;
  }
  return self;
}

- (BOOL)isOpaque {
  return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
  
  dirtyRect = [self bounds];
  [[NSGraphicsContext currentContext] saveGraphicsState];
  
  NSColor *topColor = [NSColor colorWithCalibratedWhite:0.9 alpha:1];
  NSColor *bottomColor = [NSColor colorWithCalibratedWhite:0.85 alpha:1];
  NSGradient *gradient = [[NSGradient alloc] initWithColors:@[topColor, bottomColor ]];
  [gradient drawInRect:dirtyRect angle:-90];
  
  NSShadow *dropShadow = [[NSShadow alloc] init];
  [dropShadow setShadowColor:[NSColor colorWithCalibratedWhite:0 alpha:0.5]];
  [dropShadow setShadowBlurRadius:10];
  [dropShadow set];
  [[NSColor redColor] set]; // Use red to show visual errors
  
  if(0 != (self.shadowDisplay & MPShadowTop)) {
    [dropShadow setShadowOffset:NSMakeSize(0, -SHADOW_OFFSET)];
    NSRect topElispis = NSMakeRect(0, dirtyRect.size.height + ELIPSIS_OFFSET, dirtyRect.size.width, ELIPSIS_HEIGHT);
    [[NSBezierPath bezierPathWithOvalInRect:topElispis] fill];
  }
  if(0 != (self.shadowDisplay & MPShadowBottom)) {
    NSRect bottomElipsis = NSMakeRect(0, - ( ELIPSIS_OFFSET + ELIPSIS_HEIGHT ), dirtyRect.size.width, ELIPSIS_HEIGHT);
    [dropShadow setShadowOffset:NSMakeSize(0, SHADOW_OFFSET)];
    [[NSBezierPath bezierPathWithOvalInRect:bottomElipsis] fill];
  }
  
  [[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)setShadowDisplay:(MPShadowDisplay)shadowDisplay {
  if(_shadowDisplay != shadowDisplay) {
    _shadowDisplay = shadowDisplay;
    [self setNeedsDisplay:YES];
  }
}

@end
