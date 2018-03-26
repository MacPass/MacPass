//
//  KPKNode+IconImage.m
//  MacPass
//
//  Created by Michael Starke on 31.08.13.
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

#import "KPKNode+IconImage.h"

#import "KeePassKit/KeePassKit.h"

#import "MPIconHelper.h"

@interface NSImage (MPTintedImage)
@end
@implementation NSImage (MPTintedImage)
- (NSImage *)imageWithTintColor:(NSColor *)tintColor {
  /* only tint tempated images! */
  if(NO == self.template) {
    return self;
  }
  NSImage *image = [self copy];
  [image lockFocus];
  [tintColor set];
  NSRectFillUsingOperation(NSMakeRect(0, 0, image.size.width, image.size.height), NSCompositingOperationSourceAtop);
  [image unlockFocus];
  image.template = NO;
  return image;
}
@end

@implementation KPKNode (IconImage)

+ (NSSet *)keyPathsForValuesAffectingIconImage {
  static NSString *expireDateKeyPath;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    expireDateKeyPath = [[NSString alloc] initWithFormat:@"%@.%@", NSStringFromSelector(@selector(timeInfo)), NSStringFromSelector(@selector(isExpired))];
  });
  return [NSSet setWithArray:@[NSStringFromSelector(@selector(iconUUID)),
                               NSStringFromSelector(@selector(iconId)),
                               NSStringFromSelector(@selector(backgroundColor)),
                               expireDateKeyPath
                               ]];
}

- (NSImage *)iconImage {
  
  if(self.timeInfo.isExpired) {
    const BOOL isGroup = [self isKindOfClass:[KPKGroup class]];
    return [MPIconHelper icon:(isGroup ? MPIconExpiredGroup : MPIconExpiredEntry)];
  }
  if(self.icon) {
    return self.icon.image;
  }
  if(self.asEntry.backgroundColor) {
    return [[MPIconHelper icon:(MPIconType)self.iconId] imageWithTintColor:self.asEntry.backgroundColor];
  }
  return [MPIconHelper icon:(MPIconType)self.iconId];
}

@end
