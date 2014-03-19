//
//  MPTemporaryFileStorageCleaner.m
//  MacPass
//
//  Created by Michael Starke on 19/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPTemporaryFileStorageCenter.h"
#import "MPTemporaryFileStorage.h"

@interface MPTemporaryFileStorageCenter () {
  NSMutableArray *_storages;
}

@end

@implementation MPTemporaryFileStorageCenter

+ (instancetype)defaultCenter {
  static MPTemporaryFileStorageCenter *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[MPTemporaryFileStorageCenter alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if(self) {
    _storages = [[NSMutableArray alloc] init];
  }
  return self;
}

- (BOOL)hasPendingStorages {
  return  [_storages count] > 0;
}

- (MPTemporaryFileStorage *)storageForBinary:(KPKBinary *)binary {
  return [[MPTemporaryFileStorage alloc] initWithBinary:binary];
}

- (void)cleanupStorages {
  for(MPTemporaryFileStorage *storage in _storages) {
    [storage cleanupNow];
  }
  _storages = nil;
}

- (void)registerStorage:(MPTemporaryFileStorage *)storage {
  [_storages addObject:storage];
}

- (void)unregisterStorage:(MPTemporaryFileStorage *)storage {
  [storage cleanup];
  [_storages removeObject:storage];
}

@end
