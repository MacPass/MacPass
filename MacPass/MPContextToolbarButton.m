//
//  MPSegmentedToolbarButton.m
//  MacPass
//
//  Created by Michael Starke on 26.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPContextToolbarButton.h"

@implementation MPContextToolbarButton

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setFocusRingType:NSFocusRingTypeNone];
    [self setSegmentCount:2];
    [[self cell] setWidth:15 forSegment:1];
    [[self cell] setTrackingMode:NSSegmentSwitchTrackingMomentary];
    [self setSegmentStyle:NSSegmentStyleTexturedSquare];
  }
  
  return self;
}
/*
 Block the segment setter to prevent accidential settings
 */
- (void)setImage:(NSImage *)image forSegment:(NSInteger)segment {
  if(segment == 0) {
    [super setImage:image forSegment:segment];
  }
}

- (void)setSegmentCount:(NSInteger)count {
  if(count == 2) {
    [super setSegmentCount:count];
  }
}

- (void)setImage:(NSImage *)image {
  [self setImage:image forSegment:0];
}

@end
