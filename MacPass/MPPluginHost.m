//
//  MPPluginHost.m
//  MacPass
//
//  Created by Michael Starke on 13/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginHost.h"
#import "MPDocument.h"

@implementation MPPluginHost

static MPPluginHost *_instance;

+ (instancetype)sharedHost {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _instance = [[MPPluginHost alloc] _init];
  });
  return _instance;
}

- (instancetype)init {
  return _instance;
}

- (instancetype)_init {
  self = [super init];
  if(self) {
  }
  return self;
}

- (NSArray<KPKEntry *> *)filteredEntriesUsingBlock:(NodeMatchBlock)matchBlock {
  NSArray *currentDocuments = [[NSDocumentController sharedDocumentController] documents];
  NSMutableArray *entries = [[NSMutableArray alloc] initWithCapacity:200];
  for(MPDocument *document in currentDocuments) {
    if(document.tree) {
      [entries addObjectsFromArray:document.tree.allEntries];
    }
  }
  NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) { return matchBlock(evaluatedObject); }];
  return [[NSArray alloc] initWithArray:[entries filteredArrayUsingPredicate:predicate] copyItems:YES];
}

- (NSArray<KPKGroup *> *)filteredGroupsUsingBlock:(NodeMatchBlock)matchBlock {
  NSAssert(NO, @"Not implemented");
  return nil;
}

@end
