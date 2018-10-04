//
//  MPPluginVersionInfo.m
//  MacPass
//
//  Created by Michael Starke on 04.10.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginRepositoryItemVersionInfo.h"

NSString *const MPPluginItemCompatibiltyVersionKey = @"pluginVersion";
NSString *const MPPluginItemCompatibiltyMinimumHostVersionKey = @"minimumHostVersion";
NSString *const MPPluginItemCompatibiltyMaxiumumHostVersionKey = @"maxiumumHostVersion";

@interface MPPluginRepositoryItemVersionInfo ()

@property (copy) NSString *version;
@property (copy) NSString *minimumHostVersion;
@property (copy) NSString *maxiumHostVersion;


@end

@implementation MPPluginRepositoryItemVersionInfo

- (instancetype)initWithDict:(NSDictionary *)dict {
  self = [super init];
  if(self) {
    self.version = dict[MPPluginItemCompatibiltyVersionKey];
    self.minimumHostVersion = dict[MPPluginItemCompatibiltyMinimumHostVersionKey];
    self.maxiumHostVersion = dict[MPPluginItemCompatibiltyMaxiumumHostVersionKey];
  }
  return self;
}

@end
