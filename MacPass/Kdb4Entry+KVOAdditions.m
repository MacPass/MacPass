//
//  Kdb4Entry+KVOAdditions.m
//  MacPass
//
//  Created by Michael Starke on 28.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb4Entry+KVOAdditions.h"

@implementation Kdb4Entry (KVOAdditions)

/* Entries */
- (NSUInteger)countOfStringFields {
  return [self.stringFields count];
}

- (StringField *)objectInStringFieldsAtIndex:(NSUInteger)index {
  return (self.stringFields)[index];
}

- (void)insertObject:(StringField *)stringfield inStringFieldsAtIndex:(NSUInteger)anIndex {
  [self.stringFields insertObject:stringfield atIndex:anIndex];
}

- (void)removeObjectFromStringFieldsAtIndex:(NSUInteger)anIndex {
  [self.stringFields removeObjectAtIndex:anIndex];
}

/* Binaries */
- (NSUInteger)countOfBinaries {
  return [self.binaries count];
}

- (BinaryRef *)objectInBinariesAtIndex:(NSUInteger)index {
  return (self.binaries)[index];
}

- (void)insertObject:(BinaryRef *)binary inBinariesAtIndex:(NSUInteger)index {
  [self.binaries insertObject:binary atIndex:index];
}

- (void)removeObjectFromBinariesAtIndex:(NSUInteger)index {
  [self.binaries removeObjectAtIndex:index];
}

@end
