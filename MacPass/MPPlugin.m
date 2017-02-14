//
//  MPPlugin.m
//  MacPass
//
//  Created by Michael Starke on 11/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import "MPPlugin.h"
#import "MPPluginHost.h"
#import "MPSettingsHelper.h"

NSString *const kMPPluginFileExtension = @"mpplugin";

@implementation MPPlugin

- (instancetype)initWithPluginHost:(MPPluginHost *)host {
  self = [super init];
  return self;
}

- (NSString *)identifier {
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  if(bundle && bundle.bundleIdentifier) {
    return bundle.bundleIdentifier;
  }
  return [NSString stringWithFormat:@"unknown.bundle.identifier"];
}

- (NSString *)name {
  NSString *name = [self.identifier componentsSeparatedByString:@"."].lastObject;
  return nil == name ? @"Unkown Plugin" : name;
}

- (NSString *)version {
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSString *version;
  if(bundle) {
    version = bundle.infoDictionary[(NSString *)kCFBundleVersionKey];
    if(version) {
      return version;
    }
  }
  return @"unknown.version";
}


- (void)didLoadPlugin {

}

@end

@implementation MPPlugin (Deprecated)

- (instancetype)initWithPluginManager:(id)manager {
  NSLog(@"Deprecated initalizer. Use initWithPluginHost: instead!");
  self = [self initWithPluginManager:nil];
  return self;
}

@end
