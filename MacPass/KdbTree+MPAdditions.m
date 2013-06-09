//
//  KdbTree+MPAdditions.m
//  MacPass
//
//  Created by michael starke on 20.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbTree+MPAdditions.h"
#import "KdbGroup+MPTreeTools.h"

@implementation KdbTree (MPAdditions)

- (NSArray *)allGroups {
  return [self.root childGroups];
}

- (NSArray *)allEntries {
  return [self.root childEntries];
}

@end
