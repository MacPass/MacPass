//
//  MPContextToolbarButton.m
//  MacPass
//
//  Created by Michael Starke on 26.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
    self.cell = cell;

    self.focusRingType = NSFocusRingTypeNone;
    self.segmentCount = 2;
    cell.trackingMode = NSSegmentSwitchTrackingMomentary;
    self.segmentStyle = NSSegmentStyleTexturedSquare;
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
 Block the segment setter to prevent accidental settings
 */
- (void)setImage:(NSImage *)image forSegment:(NSInteger)segment {
  if(segment < 2) {
    [super setImage:image forSegment:segment];
  }
}

- (void)setSegmentCount:(NSInteger)count {
  if(count == 2) {
    super.segmentCount = count;
  }
}

- (void)setImage:(NSImage *)image {
  [self setImage:image forSegment:0];
}

- (void)showContextMenu:(id)sender {
  NSPoint point = self.frame.origin;
  point.x = [self.cell widthForSegment:0];
  point.y = NSHeight(self.frame) + 3;
  [_contextMenu popUpMenuPositioningItem:nil atLocation:point inView:self];
}

- (void)setControlSize:(NSControlSize)controlSize {
  NSImageRep *rep = [[self imageForSegment:0] bestRepresentationForRect:NSMakeRect(0, 0, 100, 100) context:nil hints:nil];
  CGFloat scale = rep.size.width / rep.size.height;
  switch (controlSize) {
    case NSRegularControlSize:
      [self imageForSegment:0].size = NSMakeSize(16 * scale, 16);
      break;
      
    case NSSmallControlSize:
      [self imageForSegment:0].size = NSMakeSize(14 * scale, 14);
      break;
      
    case NSMiniControlSize:
      [self imageForSegment:0].size = NSMakeSize(8 * scale, 8);
      
    default:
      break;
  }
  if([self.superclass instancesRespondToSelector:@selector(setControlSize:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    super.controlSize = controlSize;
#pragma clang diagnostic pop
  }
  else {
    self.cell.controlSize = controlSize;
  }
}

- (NSControlSize)controlSize {
  if([self.superclass instancesRespondToSelector:@selector(controlSize)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    return super.controlSize;
#pragma clang diagnostic pop
  }
  return self.cell.controlSize;
}

@end
