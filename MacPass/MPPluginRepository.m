//
//  MPPluginRepository.m
//  MacPass
//
//  Created by Michael Starke on 04.12.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginRepository.h"
#import "MPConstants.h"
#import "MPPluginRepositoryItem.h"

@implementation MPPluginRepository

@dynamic availablePlugins;

+ (instancetype)defaultRepository {
  static MPPluginRepository *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[MPPluginRepository alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  return self;
}

- (NSArray<MPPluginRepositoryItem *> *)availablePlugins {
  NSString *urlString = NSBundle.mainBundle.infoDictionary[MPBundlePluginRepositoryURLKey];
  if(!urlString) {
    return @[];
  }
  NSURL *jsonURL = [NSURL URLWithString:urlString];
  if(!jsonURL) {
    return @[];
  }
  NSError *error;
  NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL options:0 error:&error];
  if(!jsonData) {
    return @[];
  }
  id jsonRoot = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
  if(!jsonRoot || ![jsonRoot isKindOfClass:NSArray.class]) {
    return @[];
  }
  NSMutableArray *items = [[NSMutableArray alloc] init];
  for(id item in jsonRoot) {
    if(![item isKindOfClass:NSDictionary.class]) {
      continue;
    }
    MPPluginRepositoryItem *pluginItem = [MPPluginRepositoryItem pluginItemFromDictionary:item];
    if(pluginItem.isVaid) {
      [items addObject:pluginItem];
    }
  }
  return [items copy];
}

@end
