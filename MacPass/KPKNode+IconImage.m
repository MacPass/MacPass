//
//  KPKNode+IconImage.m
//  MacPass
//
//  Created by Michael Starke on 31.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKNode+IconImage.h"

#import "KPKIcon.h"
#import "KPKGroup.h"
#import "KPKTree.h"
#import "KPKMetaData.h"
#import "KPKTimeInfo.h"

#import "MPIconHelper.h"

@implementation KPKNode (IconImage)

+ (NSSet *)keyPathsForValuesAffectingIconImage {
  static NSString *expireDateKeyPath;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    expireDateKeyPath = [[NSString alloc] initWithFormat:@"%@.%@", NSStringFromSelector(@selector(timeInfo)), NSStringFromSelector(@selector(isExpired))];
  });
  return [NSSet setWithArray:@[NSStringFromSelector(@selector(iconUUID)),
                               NSStringFromSelector(@selector(iconId)),
                               expireDateKeyPath
                               ]];
}

- (NSImage *)iconImage {
  
  if(self.timeInfo.isExpired) {
    const BOOL isGroup = [self isKindOfClass:[KPKGroup class]];
    return [MPIconHelper icon:(isGroup ? MPIconExpiredGroup : MPIconExpiredEntry)];
  }
  
  if(self.iconUUID) {
    KPKIcon *icon = [self.tree.metaData findIcon:self.iconUUID];
    if(icon && icon.image) {
      return icon.image;
    }
  }
  return [MPIconHelper icon:(MPIconType)self.iconId];
}
@end
