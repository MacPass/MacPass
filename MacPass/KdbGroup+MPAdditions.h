//
//  KdbGroup+MPAdditions.h
//  MacPass
//
//  Created by michael starke on 19.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbLib.h"

@interface KdbGroup (MPAdditions)

- (NSArray *)childGroups;

- (NSArray *)childEntries;

- (void)moveEntry:(KdbEntry *)entry toIndex:(NSUInteger)index;

@end