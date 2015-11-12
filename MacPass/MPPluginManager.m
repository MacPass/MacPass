//
//  MPPluginManager.m
//  MacPass
//
//  Created by Michael Starke on 16/07/15.
//  Copyright (c) 2015 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginManager.h"

#import "MPDocument.h"
#import "MPPlugin.h"
#import "NSApplication+MPAdditions.h"

#import "KeePassKit/KeePassKit.h"

@interface MPPluginManager ()

@property (strong) NSMutableArray<MPPlugin __kindof *> *mutablePlugins;

@end

@implementation MPPluginManager

+ (instancetype)sharedManager {
  static MPPluginManager *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[MPPluginManager alloc] _init];
  });
  return instance;
}

- (instancetype)init {
  return nil;
}

- (instancetype)_init {
  self = [super init];
  if(self) {
    _mutablePlugins = [[NSMutableArray alloc] init];
  }
  return self;
}

- (NSArray<MPPlugin *> *)plugins {
  return [self.mutablePlugins copy];
}

- (NSArray *)filteredEntriesUsingBlock:(NodeMatchBlock)matchBlock {
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

- (NSArray *)filteredGroupsUsingBlock:(NodeMatchBlock)matchBlock {
  return nil;
}

- (void)loadPlugins {
  NSURL *dir = [NSApp applicationSupportDirectoryURL:YES];
  NSError *error;
  NSArray *contentURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:dir includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
  if(!contentURLs) {
    NSLog(@"Error while trying to locate Plugins: %@", error.localizedDescription);
  }
  for(NSURL *pluginURL in contentURLs) {
    MPPlugin *plugin = [MPPlugin pluginWithBundleURL:pluginURL pluginManager:self];
    if(plugin) {
      [self.mutablePlugins addObject:plugin];
    }
  }
}
@end
