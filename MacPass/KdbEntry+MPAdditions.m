//
//  KdbEntry+MPAdditions.m
//  MacPass
//
//  Created by Michael Starke on 01.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbEntry+MPAdditions.h"

#import "MPIconHelper.h"

@implementation KdbEntry (MPAdditions)

- (NSImage *)icon {
  return [MPIconHelper icon:(MPIconType)self.image];
}

@end
