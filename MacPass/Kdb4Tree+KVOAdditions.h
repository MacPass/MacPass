//
//  Kdb4Tree+KVOAdditions.h
//  MacPass
//
//  Created by Michael Starke on 27.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb4Node.h"

@interface Kdb4Tree (KVOAdditions)

- (void)insertObject:(Binary *)binary inBinariesAtIndex:(NSUInteger)index;
- (void)insertObject:(CustomIcon *)icon inCustomIconsAtIndex:(NSUInteger)index;

- (CustomIcon *)objectInCustomIconsAtIndex:(NSUInteger)index;
- (Binary *)objectInBinariesAtIndex:(NSUInteger)index;

@end
