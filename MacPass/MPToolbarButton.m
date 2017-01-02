//
//  MPToolbarButton.m
//  MacPass
//
//  Created by michael starke on 26.02.13.
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

#import "MPToolbarButton.h"
#import "HNHUi/HNHUi.h"

@implementation MPToolbarButton

- (id)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if(self) {
    self.focusRingType = NSFocusRingTypeNone;
    self.bezelStyle = NSTexturedRoundedBezelStyle;
    [self.cell setImageScaling:NSImageScaleProportionallyDown];
    [self setButtonType:NSMomentaryPushInButton];
    self.imagePosition = NSImageOnly;
  }
  return self;
}

- (void)setControlSize:(NSControlSize)controlSize {
  NSImageRep *rep = [self.image bestRepresentationForRect:NSMakeRect(0, 0, 100, 100) context:nil hints:nil];
  CGFloat scale = rep.size.width / rep.size.height;
  switch (controlSize) {
    case NSRegularControlSize:
      self.image.size = NSMakeSize(16 * scale, 16);
      break;
      
    case NSSmallControlSize:
      self.image.size = NSMakeSize(14 * scale, 14);
      break;
      
    case NSMiniControlSize:
      self.image.size = NSMakeSize(8 * scale, 8);
      
    default:
      break;
  }
  if([self.superclass instancesRespondToSelector:@selector(setControlSize:)]) {
    super.controlSize = controlSize;
  }
  else {
    self.cell.controlSize = controlSize;
  }
}

- (NSControlSize)controlSize {
  if([self.superclass instancesRespondToSelector:@selector(controlSize)]) {
    return super.controlSize;
  }
  return self.cell.controlSize;
}

@end
