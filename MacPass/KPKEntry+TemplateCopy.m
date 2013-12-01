//
//  KPKEntry+TemplateCopy.m
//  MacPass
//
//  Created by Michael Starke on 01/12/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKEntry+TemplateCopy.h"
#import "KPKTimeInfo.h"

@implementation KPKEntry (TemplateCopy)

- (instancetype)copyWithTitle:(NSString *)title {
  KPKEntry *copy = [self copy];
  copy.uuid = [[NSUUID alloc] init];
  copy.timeInfo.creationTime = [NSDate date];
  copy.title = title;
  return copy;
}

@end
