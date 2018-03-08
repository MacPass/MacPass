//
//  MPPluginRepositoryItem.m
//  MacPass
//
//  Created by Michael Starke on 08.03.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginRepositoryItem.h"


NSString *const MPPluginItemNameKey = @"name";
NSString *const MPPluginItemDescriptionKey = @"description";
NSString *const MPPluginItemDownloadURLKey = @"download";
NSString *const MPPluginItemSourceURLKey = @"source";
NSString *const MPPluginItemCurrentVersionKey = @"currentVersion";

@interface MPPluginRepositoryItem ()

@property (copy) NSString *name;
@property (copy) NSString *currentVersion;
@property (copy) NSString *descriptionText;
@property (copy) NSURL *sourceURL;
@property (copy) NSURL *downloadURL;
@property (copy) NSURL *bundleIdentifier;

@end

@implementation MPPluginRepositoryItem

@dynamic valid;

+ (instancetype)pluginItemFromDictionary:(NSDictionary *)dict {
  return [[MPPluginRepositoryItem alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super init];
  if(self) {
    self.name = dict[MPPluginItemNameKey];
    self.descriptionText = dict[MPPluginItemDescriptionKey];
    self.downloadURL = [NSURL URLWithString:dict[MPPluginItemDownloadURLKey]];
    self.sourceURL = [NSURL URLWithString:dict[MPPluginItemSourceURLKey]];
    self.currentVersion = dict[MPPluginItemCurrentVersionKey];
  }
  return self;
}

- (BOOL)isVaid {
  /* name and download seems ok */
  return (self.name.length > 0 && self.downloadURL);
}

@end
