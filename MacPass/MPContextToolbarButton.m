//
//  MPSegmentedToolbarButton.m
//  MacPass
//
//  Created by Michael Starke on 26.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPContextToolbarButton.h"
#import "MPSegmentedContextCell.h"

@interface MPContextToolbarButton () {
  @private
  NSMenu *_contextMenu;
}

@end

@implementation MPContextToolbarButton

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[self cell]];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    MPSegmentedContextCell *cell = [[MPSegmentedContextCell alloc] initWithCoder:unarchiver];
    [self setCell:cell];

    [self setFocusRingType:NSFocusRingTypeNone];
    [self setSegmentCount:2];
    [cell setTrackingMode:NSSegmentSwitchTrackingMomentary];
    [self setSegmentStyle:NSSegmentStyleTexturedSquare];
    [cell setWidth:31 forSegment:0];
    [cell setWidth:17 forSegment:1];

    NSImage *contextTriangle = [[NSBundle mainBundle] imageForResource:@"contextTriangleTemplate"];
    [self setImage:contextTriangle forSegment:1];
    
    cell.contextMenuAction = @selector(showContextMenu:);
    cell.contextMenuTarget = self;
  }
  return self;
}

- (void)setContextMenu:(NSMenu *)menu {
  if(_contextMenu != menu) {
    _contextMenu = menu;
  }
}

/*
 Block the segment setter to prevent accidential settings
 */
- (void)setImage:(NSImage *)image forSegment:(NSInteger)segment {
  if(segment < 2) {
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

- (void)showContextMenu:(id)sender {
  NSPoint point = [self frame].origin;
  point.x = [[self cell] widthForSegment:0];
  point.y = NSHeight([self frame]) + 3;
  [_contextMenu popUpMenuPositioningItem:nil atLocation:point inView:self];
}

@end
