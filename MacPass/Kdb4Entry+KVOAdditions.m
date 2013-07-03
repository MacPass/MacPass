//
//  Kdb4Entry+KVOAdditions.m
//  MacPass
//
//  Created by Michael Starke on 28.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb4Entry+KVOAdditions.h"

@implementation Kdb4Entry (KVOAdditions)

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

@end
