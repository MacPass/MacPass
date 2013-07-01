//
//  KdbGroup+MPAdditions.h
//  MacPass
//
//  Created by Michael Starke on 01.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb.h"

@interface KdbGroup (MPAdditions)

/* Adapter to load images based on icon index */
@property (nonatomic, readonly) NSImage *icon;

/* Walks the tree up to the root element */
- (KdbGroup *)root;

/* Removes all Groups and Entries from this group*/
- (void)clear;

@end
