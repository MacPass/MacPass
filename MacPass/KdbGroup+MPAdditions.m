//
//  KdbGroup+MPAdditions.m
//  MacPass
//
//  Created by Michael Starke on 01.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbGroup+MPAdditions.h"
#import "KdbGroup+KVOAdditions.h"
#import "MPIconHelper.h"

@implementation KdbGroup (MPAdditions)

- (NSImage *)icon {
  return [MPIconHelper icon:(MPIconType)self.image];
}

- (KdbGroup *)root {
  if(self.parent) {
    return [self.parent root];
  }
  return self;
}

- (void)clear {
  NSUInteger groupCount = [_groups count];
  for(NSInteger index = (groupCount - 1); index > -1; index--) {
    [self removeObjectFromGroupsAtIndex:index];
  }
  NSUInteger entryCount = [_entries count];
  for(NSInteger index = (entryCount - 1); index > -1; index--) {
    [self removeObjectFromEntriesAtIndex:index];
  }
}
@end
