//
//  KdbGroup+MPAdditions.h
//  MacPass
//
//  Created by michael starke on 19.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbLib.h"

@interface KdbGroup (MPAdditions)

+ (KdbGroup *)group;
+ (KdbGroup *)groupWithName:(NSString *)name;

+ (void)refreshModificationTime;

@end
