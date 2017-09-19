//
//  MPCollectionView.m
//  MacPass
//
//  Created by Michael Starke on 18.09.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPCollectionView.h"

@implementation MPCollectionView

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    _contextMenuIndex = NSNotFound;
  }
  return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if(self) {
    _contextMenuIndex = NSNotFound;
  }
  return self;
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
  self.contextMenuIndex = NSNotFound;
  NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
  NSUInteger count = self.content.count;
  for (NSUInteger i = 0; i < count; i++) {
    NSRect itemFrame = [self frameForItemAtIndex:i];
    if (NSMouseInRect(point, itemFrame, self.isFlipped)) {
      self.contextMenuIndex = i;
      break;
    }
  }
  
  return [super menuForEvent:event];
}

@end
