//
//  KPKGroup+TemplateCopy.m
//  MacPass
//
//  Created by Michael Starke on 01/12/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKGroup+TemplateCopy.h"
#import "KPKTimeInfo.h"

@implementation KPKGroup (TemplateCopy)

- (instancetype)copyWithName:(NSString *)name {
  KPKGroup *copy = [self copy];
  copy.uuid = [[NSUUID alloc] init];
  copy.timeInfo.creationTime = [NSDate date];
  copy.name = name;
  return copy;
}

@end
