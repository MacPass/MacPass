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
  if(self.binary) {
    return @"Dummy";
  }
  return nil;
}
- (void)removeObjectFromBinariesAtIndex:(NSUInteger)index {
  return; // Stubb
}
- (void)insertObject:(id)binary inBinariesAtIndex:(NSUInteger)index {
  return; //Stubb
}



@end
