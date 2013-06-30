//
//  KdbGroup+MPTreeTools.m
//  MacPass
//
//  Created by michael starke on 19.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbGroup+MPTreeTools.h"
#import "Kdb4Node.h"
#import "Kdb3Node.h"

@implementation KdbGroup (MPTreeTools)

- (NSArray *)childGroups {
  NSMutableArray *childGroups = [NSMutableArray arrayWithCapacity:[self.groups count]];
  [childGroups addObjectsFromArray:self.groups];
  for(KdbGroup *childGroup in self.groups) {
    [childGroups addObjectsFromArray:[childGroup childGroups]];
  }
  return childGroups;
}

- (NSArray *)childEntries {
  NSMutableArray *childEntries = [NSMutableArray arrayWithCapacity:[self.groups count] + [self.entries count]];
  [childEntries addObjectsFromArray:self.entries];
  for( KdbGroup *childGroup in self.groups) {
    [childEntries addObjectsFromArray:[childGroup childEntries]];
  }
  return childEntries;
}

- (KdbEntry *)entryForUUID:(UUID *)uuid {
  NSArray *childEntries = [self childEntries];
  NSArray *filterdEntries = [childEntries filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
    return [uuid isEqual:(UUID *)[evaluatedObject uuid]];
  }]];
  NSAssert([filterdEntries count] <= 1, @"UUID hast to be unique");
  return [filterdEntries lastObject];
}

- (KdbGroup *)groupForUUID:(UUID *)uuid {
  NSArray *childGroups = [self childGroups];
  NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
    return [uuid isEqual:(UUID *)[evaluatedObject uuid]];
  }];
  NSArray *filteredGroups = [childGroups filteredArrayUsingPredicate:predicate];
  NSAssert([filteredGroups count] <= 1, @"UUID hast to be unique");
  return  [filteredGroups lastObject];
}

@end