//
//  MPPlugin.m
//  MacPass
//
//  Created by Michael Starke on 11/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "MPPlugin.h"
#import "MPPlugin_Private.h"
#import "MPPluginHost.h"
#import "MPSettingsHelper.h"
#import "MPPluginConstants.h"
#import "MPPluginVersionComparator.h"

NSString *const MPPluginUnkownVersion = @"unkown.plugin.version";
NSString *const MPPluginDescriptionInfoDictionaryKey = @"MPPluginDescription";

@implementation MPPlugin

@synthesize bundle = _bundle;

- (instancetype)initWithPluginHost:(MPPluginHost *)host {
  self = [super init];
  if(self) {
    _enabled = YES;
  }
  return self;
}

- (NSBundle *)bundle {
  if(_enabled) {
    return [NSBundle bundleForClass:self.class];
  }
  else {
    return _bundle;
  }
}

- (void)setBundle:(NSBundle *)bundle {
  self.enabled = NO;
  if(_bundle != bundle) {
    _bundle = bundle;
  }
}

- (NSString *)identifier {
  if(self.bundle.bundleIdentifier) {
    return self.bundle.bundleIdentifier;
  }
  return [NSString stringWithFormat:@"unknown.bundle.identifier"];
}

- (NSString *)name {
  NSString *name = [self.identifier componentsSeparatedByString:@"."].lastObject;
  return nil == name ? @"Unkown Plugin" : name;
}

- (NSString *)shortVersionString {
  return self.bundle.infoDictionary[@"CFBundleShortVersionString"];
}

- (NSString *)versionString {
  if(self.bundle) {
    NSString *humanVersion = self.shortVersionString;
    NSString *version = self.bundle.infoDictionary[(NSString *)kCFBundleVersionKey];
    if(humanVersion && version) {
      return [NSString stringWithFormat:@"%@ (%@)", humanVersion, version];
    }
    else if(humanVersion) {
      return humanVersion;
    }
    else if(version) {
      return version;
    }
  }
  return MPPluginUnkownVersion;
}

- (NSString *)localizedDescription {
  if([self.bundle.localizedInfoDictionary objectForKey:MPPluginDescriptionInfoDictionaryKey]) {
    return self.bundle.localizedInfoDictionary[MPPluginDescriptionInfoDictionaryKey];
  }
  if([self.bundle.infoDictionary objectForKey:MPPluginDescriptionInfoDictionaryKey]) {
    return self.bundle.infoDictionary[MPPluginDescriptionInfoDictionaryKey];
  }
  return @"";
}


- (void)didLoadPlugin {

}

@end

@implementation MPPlugin (Deprecated)

- (instancetype)initWithPluginManager:(id)manager {
  NSLog(@"Deprecated initalizer. Use initWithPluginHost: instead!");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
  self = [self initWithPluginHost:manager];
#pragma cland diagnostic pop
  return self;
}

@end
