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
  [_entries insertObject:entry atIndex:index];
}

- (void)removeObjectFromEntriesAtIndex:(NSUInteger)index {
  KdbEntry *entry = [_entries objectAtIndex:index];
  [_entries removeObjectAtIndex:index];
  entry.parent = nil;
}

- (NSUInteger)countOfEntries {
  return [self.entries count];
}

- (KdbEntry *)objectInEntriesAtIndex:(NSUInteger)index {
  return self.entries[index];
}

- (KdbGroup *)objectInGroupsAtIndex:(NSUInteger)index {
  return self.groups[index];
}

- (NSUInteger)countOfGroups {
  return [self.groups count];
}

- (void)insertObject:(KdbGroup *)group inGroupsAtIndex:(NSUInteger)index {
  group.parent = self;
  [_groups insertObject:group atIndex:index];
}

- (void)removeObjectFromGroupsAtIndex:(NSUInteger)index {
  KdbGroup *group = [self.groups objectAtIndex:index];
  [_groups removeObjectAtIndex:index];
  group.parent = nil;
}

@end
