//
//  Kdb4Tree+KVOAdditions.m
//  MacPass
//
//  Created by Michael Starke on 27.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb4Tree+KVOAdditions.h"

@implementation Kdb4Tree (KVOAdditions)

- (void)insertObject:(Binary *)binary inBinariesAtIndex:(NSUInteger)index {
  [self.binaries insertObject:binary atIndex:index];
}

- (void)insertObject:(CustomIcon *)icon inCustomIconsAtIndex:(NSUInteger)index {
  [self.customIcons insertObject:icon atIndex:index];
}

- (Binary *)objectInBinariesAtIndex:(NSUInteger)index {
  return [self.binaries objectAtIndex:index];
}

- (CustomIcon *)objectInCustomIconsAtIndex:(NSUInteger)index {
  return [self.customIcons objectAtIndex:index];
}

@end
