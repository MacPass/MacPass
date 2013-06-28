//
//  KdbGroup+MPTreeTools.h
//  MacPass
//
//  Created by michael starke on 19.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb.h"
@class UUID;

@interface KdbGroup (MPTreeTools)

/* Returns all groups under this group and it's subgroups */
- (NSArray *)childGroups;
/* Returns all entries under this group and it's subgroups */
- (NSArray *)childEntries;
/* Returns the entry with the UUID */
- (KdbEntry *)entryForUUID:(UUID *)uuid;
/* Returns the group with the UUID */
- (KdbGroup *)groupForUUID:(UUID *)uuid;

@end