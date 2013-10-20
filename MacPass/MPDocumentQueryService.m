//
//  MPDocumentQueryService.m
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocumentQueryService.h"
#import "MPDocument.h"

#import "NSUUID+KeePassKit.h"

@interface MPDocumentQueryService () {
@private
  NSUUID *rootUuid;
}

@end

@implementation MPDocumentQueryService

+ (MPDocumentQueryService *)sharedService {
  static id instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[MPDocumentQueryService alloc] init];
  });
  return instance;
}

- (id)init {
  self = [super init];
  if (self) {
    static const uuid_t uuidBytes = {
      0x34, 0x69, 0x7a, 0x40, 0x8a, 0x5b, 0x41, 0xc0,
      0x9f, 0x36, 0x89, 0x7d, 0x62, 0x3e, 0xcb, 0x31
    };
    rootUuid = [[NSUUID alloc] initWithUUIDBytes:uuidBytes];
  }
  return self;
}

- (KPKEntry *)configurationEntry {
  /*
   We are looking in all documents,
   but only store the key in one.
   */
  NSArray *documents = [[NSDocumentController sharedDocumentController] documents];
  for(MPDocument *document in documents) {
    KPKEntry *entry = [document findEntry:rootUuid];
    if(entry) {
      return entry;
    }
  }
  return nil;
}

- (KPKEntry *)createConfigurationEntry {
  return nil;
}

@end
