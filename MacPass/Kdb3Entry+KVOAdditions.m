//
//  Kdb3Entry+KVOAdditions.m
//  MacPass
//
//  Created by Michael Starke on 19.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb3Entry+KVOAdditions.h"

@implementation Kdb3Entry (KVOAdditions)

- (NSUInteger)countOfBinaries {
  return (self.binary != nil ? 1 : 0);
}
- (id)objectInBinariesAtIndex:(NSUInteger)index {
  return self.binary;
}
- (void)removeObjectFromBinariesAtIndex:(NSUInteger)index {
  if(self.binary ) {
    self.binary = nil;
    self.binaryDesc = nil;
  }
}
- (void)insertObject:(id)binary inBinariesAtIndex:(NSUInteger)index {
  return;//
}



@end
