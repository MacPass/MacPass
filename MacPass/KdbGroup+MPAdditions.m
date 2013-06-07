//
//  KdbGroup+MPAdditions.m
//  MacPass
//
//  Created by michael starke on 19.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbGroup+MPAdditions.h"

@implementation KdbGroup (MPAdditions)

- (NSArray *)childGroups {
  NSMutableArray *childGroups = [NSMutableArray arrayWithCapacity:[self.groups count]];
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

- (void)moveEntry:(KdbEntry *)entry toIndex:(NSUInteger)index {
  if([entries count] > index) {
    return;
  }
  NSUInteger oldIndex = [entries indexOfObject:entry];
  if(oldIndex == NSNotFound) {
    return;
  }
  [entries exchangeObjectAtIndex:oldIndex withObjectAtIndex:index];
}

@end