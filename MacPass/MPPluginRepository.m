//
//  MPPluginRepository.m
//  MacPass
//
//  Created by Michael Starke on 04.12.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginRepository.h"
#import "MPConstants.h"

NSString *const MPPluginItemNameKey = @"name";
NSString *const MPPluginItemDescriptionKey = @"description";
NSString *const MPPluginItemDownloadURLKey = @"download";
NSString *const MPPluginItemSourceURLKey = @"source";
NSString *const MPPluginItemVersionKey = @"version";

@implementation MPPluginRespositoryItem

@dynamic valid;

+ (instancetype)pluginItemFromDictionary:(NSDictionary *)dict {
  return [[MPPluginRespositoryItem alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super init];
  if(self) {
    self.name = dict[MPPluginItemNameKey];
    self.descriptionText = dict[MPPluginItemDescriptionKey];
    self.downloadURL = [NSURL URLWithString:dict[MPPluginItemDownloadURLKey]];
    self.sourceURL = [NSURL URLWithString:dict[MPPluginItemSourceURLKey]];
    self.version = dict[MPPluginItemVersionKey];
  }
  return self;
}

- (BOOL)isVaid {
  /* name and download seems ok */
  return (self.name.length > 0 && self.downloadURL);
}

@end

@implementation MPPluginRepository

@dynamic availablePlugins;

+ (instancetype)sharedRespoitory {
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

- (NSArray<MPPluginRespositoryItem *> *)availablePlugins {
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
    MPPluginRespositoryItem *pluginItem = [MPPluginRespositoryItem pluginItemFromDictionary:item];
    if(pluginItem.isVaid) {
      [items addObject:pluginItem];
    }
  }
  return [items copy];
}

@end
