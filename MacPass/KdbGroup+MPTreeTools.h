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
/**
 *	Searches through all subgroups and loactes the Group with the given UUID
 *	@param	uuid	UUID of the searched group
 *	@return	group with matching UUID, otherwise nil
 */
- (KdbGroup *)groupForUUID:(UUID *)uuid;
/**
 *	Determines, if the reciever is an anchestor of the given group
 *	@param	group	The group to test for anchestry
 *	@return	YES, if the receiver is an anchestor of group
 */
- (BOOL)isAnchestorOfGroup:(KdbGroup *)group;

@end