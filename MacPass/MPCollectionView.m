//
//  MPCollectionView.m
//  MacPass
//
//  Created by Michael Starke on 18.09.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
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
