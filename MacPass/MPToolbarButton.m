//
//  MPButton.m
//  MacPass
//
//  Created by michael starke on 26.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPToolbarButton.h"

@implementation MPToolbarButton

- (id)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if(self) {
    [self setFocusRingType:NSFocusRingTypeNone];
  }
  return self;
}

- (void)setControlSize:(NSControlSize)controlSize {
  [[self cell] setControlSize:controlSize];
  NSImageRep *rep = [[self image] bestRepresentationForRect:NSMakeRect(0, 0, 100, 100) context:nil hints:nil];
  CGFloat scale = rep.size.width / rep.size.height;
  switch (controlSize) {
    case NSRegularControlSize:
      [[self image] setSize:NSMakeSize(16 * scale, 16)];
      break;
      
    case NSSmallControlSize:
      [[self image] setSize:NSMakeSize(14 * scale, 14)];
      break;
      
    case NSMiniControlSize:
      [[self image] setSize:NSMakeSize(8 * scale, 8)];
      
    default:
      break;
  }
}

- (NSControlSize)controlSize {
  return [[self cell] controlSize];
}

@end
