//
//  MPShadowBox.m
//  MacPass
//
//  Created by Michael Starke on 07.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

static CGFloat kMPElipsisOffset = 0.0;
static CGFloat kMPElipsisHeight = 20.0;
static CGFloat kMPShadowOffset = 10.0;

#import "MPShadowBox.h"
#import "MPFlagsHelper.h"

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
  
  dirtyRect = self.bounds;
  [[NSGraphicsContext currentContext] saveGraphicsState];
  
  NSColor *topColor = [NSColor colorWithCalibratedWhite:0.9 alpha:1];
  NSColor *bottomColor = [NSColor colorWithCalibratedWhite:0.85 alpha:1];
  NSGradient *gradient = [[NSGradient alloc] initWithColors:@[topColor, bottomColor ]];
  [gradient drawInRect:dirtyRect angle:-90];
  
  NSShadow *dropShadow = [[NSShadow alloc] init];
  dropShadow.shadowColor = [NSColor colorWithCalibratedWhite:0 alpha:0.5];
  dropShadow.shadowBlurRadius = 10;
  [dropShadow set];
  [[NSColor redColor] set]; // Use red to show visual errors
  
  
  if(MPIsFlagSetInOptions(MPShadowTop, self.shadowDisplay)) {
    dropShadow.shadowOffset = NSMakeSize(0, -kMPShadowOffset);
    NSRect topElispis = NSMakeRect(0, dirtyRect.size.height + kMPElipsisOffset, dirtyRect.size.width, kMPElipsisHeight);
    [[NSBezierPath bezierPathWithOvalInRect:topElispis] fill];
  }
  if(MPIsFlagSetInOptions(MPShadowBottom, self.shadowDisplay)) {
    NSRect bottomElipsis = NSMakeRect(0, - ( kMPElipsisOffset + kMPElipsisHeight ), dirtyRect.size.width, kMPElipsisHeight);
    dropShadow.shadowOffset = NSMakeSize(0, kMPShadowOffset);
    [[NSBezierPath bezierPathWithOvalInRect:bottomElipsis] fill];
  }
  
  [[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)setShadowDisplay:(MPShadowDisplay)shadowDisplay {
  if(_shadowDisplay != shadowDisplay) {
    _shadowDisplay = shadowDisplay;
    self.needsDisplay = YES;
  }
}

@end
