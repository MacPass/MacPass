//
//  KdbGroup+KVOAdditions.h
//  MacPass
//
//  Created by Michael Starke on 08.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb.h"

@interface KdbGroup (KVOAdditions)

/* KVO Accesors for the entries */
- (KdbEntry *)objectInEntriesAtIndex:(NSUInteger)index;
- (NSUInteger)countOfEntries;
- (void)insertObject:(KdbEntry *)entry inEntriesAtIndex:(NSUInteger)index;
- (void)removeObjectFromEntriesAtIndex:(NSUInteger)index;

/* KVO Accessors for the groups */
- (KdbGroup *)objectInGroupsAtIndex:(NSUInteger)index;
- (NSUInteger)countOfGroups;
- (void)insertObject:(KdbGroup *)group inGroupsAtIndex:(NSUInteger)index;
- (void)removeObjectFromGroupsAtIndex:(NSUInteger)index;

@end
