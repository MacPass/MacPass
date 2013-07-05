//
//  KdbTree+MPAdditions.h
//  MacPass
//
//  Created by michael starke on 20.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb.h"

@class BinaryRef;
@class Binary;

@interface KdbTree (MPAdditions)

- (NSArray *)allEntries;

- (NSArray *)allGroups;

@end
