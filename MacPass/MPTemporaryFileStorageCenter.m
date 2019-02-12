//
//  MPTemporaryFileStorageCleaner.m
//  MacPass
//
//  Created by Michael Starke on 19/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
  return  _storages.count > 0;
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
