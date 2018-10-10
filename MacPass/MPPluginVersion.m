//
//  MPPluginVersion.m
//  MacPass
//
//  Created by Michael Starke on 05.10.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginVersion.h"

NSString *MPPluginVersionWildcard = @"*";

@interface MPPluginVersion ()

@property (nonatomic, copy) NSString *versionString;
@property (nonatomic, copy) NSString *mayorVersion;
@property (nonatomic, copy) NSString *minorVersion;
@property (nonatomic, copy) NSString *patchVersion;

@end

@implementation MPPluginVersion

+ (instancetype)versionWithVersionString:(NSString *)versionString {
  return [[MPPluginVersion alloc] initWithVersionString:versionString];
}

- (instancetype)initWithVersionString:(NSString *)versionString {
  self = [super init];
  if(self) {
    self.mayorVersion = @"0";
    self.minorVersion = @"0";
    self.patchVersion = @"0";
    
    NSArray<NSString *>* components = [versionString componentsSeparatedByString:@"."];
    if(components.count >= 1) {
      
      NSString *mayorVersion = components[0].length > 0 ? components[0] : @"0";
      if([mayorVersion isEqualToString:MPPluginVersionWildcard]) {
        self.mayorVersion = MPPluginVersionWildcard;
        self.minorVersion = MPPluginVersionWildcard;
        self.patchVersion = MPPluginVersionWildcard;
        self.versionString = [NSString stringWithFormat:@"%@.%@.%@", self.mayorVersion, self.minorVersion, self.patchVersion];
        return self;
      }
      NSCharacterSet *invalidSet = NSCharacterSet.decimalDigitCharacterSet.invertedSet;
      NSRange mayorRange = [mayorVersion rangeOfCharacterFromSet:invalidSet];
      if(mayorRange.location != NSNotFound) {
        NSLog(@"Invalid Format for Mayor Version");
        self = nil;
        return self;
      }
      self.mayorVersion = mayorVersion;
      
      if(components.count >= 2) {
        NSString *minorVersion = components[1].length > 0 ? components[1] : @"0";
        if([minorVersion isEqualToString:MPPluginVersionWildcard]) {
          self.minorVersion = MPPluginVersionWildcard;
          self.patchVersion = MPPluginVersionWildcard;
          self.versionString = [NSString stringWithFormat:@"%@.%@.%@", self.mayorVersion, self.minorVersion, self.patchVersion];
          return self;
        }
        NSRange minorRange = [minorVersion rangeOfCharacterFromSet:invalidSet];
        if(minorRange.location != NSNotFound) {
          NSLog(@"Invalid Format for Minor Version");
          self.versionString = [NSString stringWithFormat:@"%@.%@.%@", self.mayorVersion, self.minorVersion, self.patchVersion];
          self = nil;
          return self;
        }
        self.minorVersion = minorVersion;
        
        if(components.count == 3) {
          NSString *patchVersion = components[2].length > 0 ? components[2] : @"0";
          if([patchVersion isEqualToString:MPPluginVersionWildcard]) {
            self.patchVersion = MPPluginVersionWildcard;
            self.versionString = [NSString stringWithFormat:@"%@.%@.%@", self.mayorVersion, self.minorVersion, self.patchVersion];
            return self;
          }
          NSRange patchRange = [patchVersion rangeOfCharacterFromSet:invalidSet];
          if(patchRange.location != NSNotFound) {
            NSLog(@"Invalid Format for Patch Version");
            self = nil;
            return self;
          }
          self.patchVersion = patchVersion;
        }
      }
    }
    self.versionString = [NSString stringWithFormat:@"%@.%@.%@", self.mayorVersion, self.minorVersion, self.patchVersion];
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  return self;
}

- (NSComparisonResult)compare:(MPPluginVersion *)version {
  if([self.versionString isEqualToString:version.versionString]) {
    return NSOrderedSame;
  }

  NSArray<NSString *> *myVersions = @[self.mayorVersion, self.minorVersion, self.patchVersion];
  NSArray<NSString *> *otherVersions = @[version.mayorVersion, version.minorVersion, version.patchVersion];
  
  for(NSUInteger index = 0; index < 3; index++) {
    NSString *myVersion = myVersions[index];
    NSString *otherVersion = otherVersions[index];
    
    if([myVersion isEqualToString:MPPluginVersionWildcard] || [otherVersion isEqualToString:MPPluginVersionWildcard]) {
      return NSOrderedSame;
    }
    
    NSComparisonResult compare = [myVersion compare:otherVersion options:NSNumericSearch|NSCaseInsensitiveSearch];
    if(compare != NSOrderedSame) {
      return compare;
    }
  }
  return NSOrderedSame;
}

@end
