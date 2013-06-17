//
//  MPDocumentQueryService.m
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocumentQueryService.h"
#import "MPDocument.h"
#import "UUID.h"

@interface MPDocumentQueryService () {
@private
  UUID *rootUuid;
}

@end

@implementation MPDocumentQueryService

+ (MPDocumentQueryService *)defaultService {
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
    static const Byte uuidBytes[] = {
      0x34, 0x69, 0x7a, 0x40, 0x8a, 0x5b, 0x41, 0xc0,
      0x9f, 0x36, 0x89, 0x7d, 0x62, 0x3e, 0xcb, 0x31
    };
    NSData *data = [NSData dataWithBytes:uuidBytes length:16];
    rootUuid = [[UUID alloc] initWithData:data];
  }
  return self;
}

- (void)dealloc
{
  [rootUuid release];
  [super dealloc];
}

- (KdbEntry *)configurationEntry {
  /*
   We are looking in all document,
   but only store the key in one.
   */
  NSArray *documents = [[NSDocumentController sharedDocumentController] documents];
  for(MPDocument *document in documents) {
    KdbEntry *entry = [document findEntry:rootUuid];
    if(entry) {
      return entry;
    }
  }
  return nil;
}

- (KdbEntry *)createConfigurationEntry {
  return nil;
}

@end
