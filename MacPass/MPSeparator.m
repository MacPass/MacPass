//
//  MPSeparator.m
//  MacPass
//
//  Created by Michael Starke on 31.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPSeparator.h"

@implementation MPSeparator

- (void)drawRect:(NSRect)dirtyRect {
  NSRect bounds = [self bounds];
  [[NSColor lightGrayColor] set];
  NSRectFill(NSMakeRect(0, 1, NSWidth(bounds), 1));
  
  [[NSColor whiteColor] set];
  NSRectFill(NSMakeRect(0, 0, NSWidth(bounds), 1));
  
}

@end
