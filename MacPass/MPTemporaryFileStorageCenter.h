//
//  MPTemporaryFileStorageCleaner.h
//  MacPass
//
//  Created by Michael Starke on 19/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPTemporaryFileStorage;
@class KPKBinary;

@interface MPTemporaryFileStorageCenter : NSObject

+ (instancetype)defaultCenter;

- (BOOL)hasPendingStorages;

- (MPTemporaryFileStorage *)storageForBinary:(KPKBinary *)binary;
- (void)registerStorage:(MPTemporaryFileStorage *)storage;
- (void)unregisterStorage:(MPTemporaryFileStorage *)storage;
- (void)cleanupStorages;

@end
