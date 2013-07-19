//
//  Kdb3Entry+KVOAdditions.h
//  MacPass
//
//  Created by Michael Starke on 19.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb3Node.h"

@interface Kdb3Entry (KVOAdditions)

- (NSUInteger)countOfBinaries;
- (id)objectInBinariesAtIndex:(NSUInteger)index;
- (void)removeObjectFromBinariesAtIndex:(NSUInteger)index;
- (void)insertObject:(id)binary inBinariesAtIndex:(NSUInteger)index;

@end
