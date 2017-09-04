//
//  MPOverlayView.m
//  MacPass
//
//  Created by Michael Starke on 03.03.13.
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

#import "MPOverlayView.h"

@implementation MPOverlayView

- (void)drawRect:(NSRect)dirtyRect {
  [NSGraphicsContext.currentContext saveGraphicsState];
  [NSColor.clearColor set];
  NSRectFill(self.bounds);
  NSColor *backgroundColor = [NSColor colorWithCalibratedWhite:0 alpha:0.7];
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:10 yRadius:10];
  [backgroundColor set];
  [path fill];
  [NSGraphicsContext.currentContext restoreGraphicsState];
}

- (BOOL)isOpaque {
  return NO;
}

@end
