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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
  self = [self initWithPluginHost:nil];
#pragma cland diagnostic pop
  return self;
}

@end
