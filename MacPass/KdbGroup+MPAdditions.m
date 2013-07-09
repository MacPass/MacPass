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
  for(KdbGroup *group in self.groups) {
    [group clear];
    NSUInteger index = [self.groups indexOfObject:group];
    [self removeObjectFromGroupsAtIndex:index];
  }
  for(KdbEntry *entry in self.entries) {
    NSUInteger index = [self.entries indexOfObject:entry];
    [self removeObjectFromEntriesAtIndex:index];
  }
}
@end
