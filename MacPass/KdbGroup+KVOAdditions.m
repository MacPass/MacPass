//
//  KdbGroup+KVOAdditions.m
//  MacPass
//
//  Created by Michael Starke on 08.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbGroup+KVOAdditions.h"

@implementation KdbGroup (KVOAdditions)

- (void)insertObject:(KdbEntry *)entry inEntriesAtIndex:(NSUInteger)index {
  entry.parent = self;
  [entries insertObject:entry atIndex:index];
}

- (void)removeObjectFromEntriesAtIndex:(NSUInteger)index {
  KdbEntry *entry = [entries objectAtIndex:index];
  [entries removeObjectAtIndex:index];
  entry.parent = nil;
}

- (NSUInteger)countOfEntries {
  return [entries count];
}

- (KdbEntry *)objectInEntriesAtIndex:(NSUInteger)index {
  return entries[index];
}

- (KdbGroup *)objectInGroupsAtIndex:(NSUInteger)index {
  return groups[index];
}

- (NSUInteger)countOfGroups {
  return [groups count];
}

- (void)insertObject:(KdbGroup *)group inGroupsAtIndex:(NSUInteger)index {
  group.parent = self;
  [groups insertObject:group atIndex:index];
}

- (void)removeObjectFromGroupsAtIndex:(NSUInteger)index {
  KdbGroup *group = [groups objectAtIndex:index];
  [groups removeObjectAtIndex:index];
  group.parent = nil;
}

@end
