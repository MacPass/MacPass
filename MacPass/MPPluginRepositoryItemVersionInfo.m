//
//  MPPluginVersionInfo.m
//  MacPass
//
//  Created by Michael Starke on 04.10.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginRepositoryItemVersionInfo.h"
#import "MPPluginVersion.h"

NSString *const MPPluginItemCompatibiltyVersionKey = @"pluginVersion";
NSString *const MPPluginItemCompatibiltyMinimumHostVersionKey = @"minimumHostVersion";
NSString *const MPPluginItemCompatibiltyMaxiumumHostVersionKey = @"maximumHostVersion";

@interface MPPluginRepositoryItemVersionInfo ()

@property (copy) MPPluginVersion *version;
@property (copy) MPPluginVersion *minimumHostVersion;
@property (copy) MPPluginVersion *maxiumHostVersion;

@end

@implementation MPPluginRepositoryItemVersionInfo

+ (instancetype)versionInfoWithDict:(NSDictionary *)dict {
  return [[MPPluginRepositoryItemVersionInfo alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict {
  self = [super init];
  if(self) {
    NSString *versionString = dict[MPPluginItemCompatibiltyVersionKey];
    if(!versionString) {
      NSLog(@"Version information is missing required %@ key.", MPPluginItemCompatibiltyVersionKey);
      self = nil;
      return self;
    }
    self.version = [MPPluginVersion versionWithVersionString:versionString];
    if(!self.version) {
      NSLog(@"Malformed plugin version information: %@.", versionString);
      self = nil;
      return self;
    }
    NSString *minimumHostVersionString = dict[MPPluginItemCompatibiltyMinimumHostVersionKey];
    if(!minimumHostVersionString) {
      NSLog(@"Version information is missing required %@ key.", MPPluginItemCompatibiltyMinimumHostVersionKey);
      self = nil;
      return self;
    }
    self.minimumHostVersion = [MPPluginVersion versionWithVersionString:minimumHostVersionString];
    if(!self.minimumHostVersion) {
      NSLog(@"Malformed minimum host version information: %@.", minimumHostVersionString);
      self = nil;
      return self;
    }
    NSString *maxiumHostVersionString = dict[MPPluginItemCompatibiltyMaxiumumHostVersionKey];
    if(maxiumHostVersionString) {
      self.maxiumHostVersion = [MPPluginVersion versionWithVersionString:maxiumHostVersionString];
      if(!self.maxiumHostVersion) {
        NSLog(@"Malformed maxium host version information: %@.", maxiumHostVersionString);
        self = nil;
        return self;
      }
    }
  }
  return self;
}

- (BOOL)isCompatibleWithHostVersion:(MPPluginVersion *)hostVersion {
  if(NSOrderedDescending == [self.minimumHostVersion compare:hostVersion]) {
    return NO;
  }
  if(!self.maxiumHostVersion) {
    return YES;
  }
  return (NSOrderedAscending != [self.maxiumHostVersion compare:hostVersion]);
}


@end
