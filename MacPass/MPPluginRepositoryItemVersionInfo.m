//
//  MPPluginVersionInfo.m
//  MacPass
//
//  Created by Michael Starke on 04.10.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginRepositoryItemVersionInfo.h"
#import "MPPluginVersionComparator.h"

NSString *const MPPluginItemCompatibiltyVersionKey = @"pluginVersion";
NSString *const MPPluginItemCompatibiltyMinimumHostVersionKey = @"minimumHostVersion";
NSString *const MPPluginItemCompatibiltyMaxiumumHostVersionKey = @"maximumHostVersion";

@interface MPPluginRepositoryItemVersionInfo ()

@property (copy) NSString *version;
@property (copy) NSString *minimumHostVersion;
@property (copy) NSString *maxiumHostVersion;

@end

@implementation MPPluginRepositoryItemVersionInfo

+ (instancetype)versionInfoWithDict:(NSDictionary *)dict {
  return [[MPPluginRepositoryItemVersionInfo alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict {
  self = [super init];
  if(self) {
    self.version = dict[MPPluginItemCompatibiltyVersionKey];
    self.minimumHostVersion = dict[MPPluginItemCompatibiltyMinimumHostVersionKey];
    self.maxiumHostVersion = dict[MPPluginItemCompatibiltyMaxiumumHostVersionKey];
  }
  return self;
}

- (BOOL)isCompatibleWithHostVersion:(NSString *)hostVersion {
  if(NSOrderedDescending == [MPPluginVersionComparator compareVersion:self.minimumHostVersion toVersion:hostVersion]) {
    return NO;
  }
  if(!self.maxiumHostVersion) {
    return YES;
  }
  return (NSOrderedAscending != [MPPluginVersionComparator compareVersion:self.maxiumHostVersion toVersion:hostVersion]);
}


@end
