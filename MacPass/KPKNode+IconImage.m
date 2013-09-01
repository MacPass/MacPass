//
//  KPKNode+IconImage.m
//  MacPass
//
//  Created by Michael Starke on 31.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKNode+IconImage.h"

#import "KPKIcon.h"

#import "MPIconHelper.h"

@implementation KPKNode (IconImage)

- (NSImage *)iconImage {
  if([self respondsToSelector:@selector(customIconUuid)]) {
    // find the custom icon
  }
  if(self.customIcon) {
    return self.customIcon.image;
  }
  return [MPIconHelper icon:(MPIconType)self.icon];
}
@end
