//
//  KPKNode+IconImage.m
//  MacPass
//
//  Created by Michael Starke on 31.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKNode+IconImage.h"

#import "KPKIcon.h"
#import "KPKTree.h"
#import "KPKMetaData.h"

#import "MPIconHelper.h"

@implementation KPKNode (IconImage)

+ (NSSet *)keyPathsForValuesAffectingIconImage {
  return [NSSet setWithArray:@[@"iconUUID", @"iconId"]];
}

- (NSImage *)iconImage {
  if(self.iconUUID) {
    KPKIcon *icon = [self.tree.metaData findIcon:self.iconUUID];
    if(icon && icon.image) {
      return icon.image;
    }
  }
  return [MPIconHelper icon:(MPIconType)self.iconId];
}
@end
