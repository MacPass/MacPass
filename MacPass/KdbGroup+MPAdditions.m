//
//  KdbGroup+MPAdditions.m
//  MacPass
//
//  Created by michael starke on 19.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbGroup+MPAdditions.h"

@implementation KdbGroup (MPAdditions)

+ (KdbGroup *)group {
  KdbGroup *group = [[KdbGroup alloc] init];
  [group setName:@"Default"];
  return [group autorelease];
}

+ (KdbGroup *)groupWithName:(NSString *)name {
  KdbGroup *group = [KdbGroup group];
  [group setName:name];
  return group;
}
@end
