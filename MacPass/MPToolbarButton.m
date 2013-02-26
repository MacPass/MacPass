//
//  MPButton.m
//  MacPass
//
//  Created by michael starke on 26.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPToolbarButton.h"

@implementation MPToolbarButton

- (void)setControlSize:(NSControlSize)controlSize {
  [[self cell] setControlSize:controlSize];
  switch (controlSize) {
    case NSRegularControlSize:
      [[self image] setSize:NSMakeSize(16, 16)];
      break;
    
    case NSSmallControlSize:
      [[self image] setSize:NSMakeSize(14, 14)];
      break;
    
    case NSMiniControlSize:
      [[self image] setSize:NSMakeSize(8, 8)];
    
    default:
      break;
  }
}

- (NSControlSize)controlSize {
  return [[self cell] controlSize];
}

@end
