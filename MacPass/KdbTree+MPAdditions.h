//
//  KdbTree+MPAdditions.h
//  MacPass
//
//  Created by michael starke on 20.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb.h"

@class BinaryRef;

@interface KdbTree (MPAdditions)

- (NSArray *)allEntries;

- (NSArray *)allGroups;

- (void)addAttachment:(NSURL *)location toEntry:(KdbEntry *)anEntry;
- (void)saveAttachmentFromEntry:(KdbEntry *)anEntry toLocation:(NSURL *)location;
- (void)saveAttachment:(BinaryRef *)reference toLocation:(NSURL *)location;
- (NSUInteger)nextBinaryId;


@end
