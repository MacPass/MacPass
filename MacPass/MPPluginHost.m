//
//  MPPluginHost.m
//  MacPass
//
//  Created by Michael Starke on 16/07/15.
//  Copyright (c) 2015 HicknHack Software GmbH. All rights reserved.
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

#import "MPPluginHost.h"

#import "MPPlugin.h"
#import "NSApplication+MPAdditions.h"
#import "MPSettingsHelper.h"

#import "KeePassKit/KeePassKit.h"


NSString *const MPPluginHostWillLoadPlugin = @"com.hicknhack.macpass.MPPluginHostWillLoadPlugin";
NSString *const MPPluginHostDidLoadPlugin = @"comt.hicknhack.macpass.MPPluginHostDidLoadPlugin";

NSString *const MPPluginHostPluginBundleIdentifiyerKey = @"MPPluginHostPluginBundleIdentifiyerKey";


@interface MPPluginHost ()

@property (strong) NSMutableArray<MPPlugin __kindof *> *mutablePlugins;
@property (nonatomic) BOOL loadUnsecurePlugins;

@end

@implementation MPPluginHost

+ (NSSet *)keyPathsForValuesAffectingPlugins {
  return [NSSet setWithObject:NSStringFromSelector(@selector(mutablePlugins))];
}

+ (instancetype)sharedHost {
  static MPPluginHost *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[MPPluginHost alloc] _init];
  });
  return instance;
}

- (instancetype)init {
  return nil;
}

- (instancetype)_init {
  self = [super init];
  if(self) {
    _mutablePlugins = [[NSMutableArray alloc] init];
    _loadUnsecurePlugins = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyLoadUnsecurePlugins];
    [self _loadPlugins];
    
    [self bind:NSStringFromSelector(@selector(loadUnsecurePlugins))
      toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyLoadUnsecurePlugins]
       options:nil];
  }
  return self;
}

- (NSArray<MPPlugin *> *)plugins {
  return [self.mutablePlugins copy];
}

- (void)_loadPlugins {
  NSURL *appSupportDir = [NSApp applicationSupportDirectoryURL:YES];
  NSError *error;
  NSArray *externalPluginsURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:appSupportDir
                                                               includingPropertiesForKeys:@[]
                                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                    error:&error];
  
  NSArray *internalPluginsURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSBundle mainBundle].builtInPlugInsURL
                                                               includingPropertiesForKeys:@[]
                                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                    error:&error];
  
  
  if(!externalPluginsURLs) {
    // No external plugins
    NSLog(@"No external plugins found!");
  }
  if(!internalPluginsURLs) {
    // No internal plugins
    NSLog(@"No internal plugins found!");
  }
  NSArray *pluginURLs = [externalPluginsURLs arrayByAddingObjectsFromArray:internalPluginsURLs];
  
  for(NSURL *pluginURL in pluginURLs) {
    
    if(![self _validURL:pluginURL]) {
      continue;
    }
    
    if(![self _validSignature:pluginURL]) {
      continue;
    }
    
    NSBundle *pluginBundle = [NSBundle bundleWithURL:pluginURL];
    if(!pluginBundle) {
      NSLog(@"Could not create bundle %@", pluginURL.path);
      continue;
    }
    NSError *error;
    if(![pluginBundle preflightAndReturnError:&error]) {
      NSLog(@"Preflight Error %@ %@", error.localizedDescription, error.localizedFailureReason );
      continue;
    };
    
    if([self _validateUniqueBundle:pluginBundle]) {
      NSLog(@"Plugin %@ already loaded!", pluginBundle.bundleIdentifier);
      continue;
    }
    
    if(![pluginBundle loadAndReturnError:&error]) {
      NSLog(@"Bunlde Loading Error %@ %@", error.localizedDescription, error.localizedFailureReason);
      continue;
    }
    
    if(![self _validateClass:pluginBundle.principalClass]) {
      NSLog(@"Wrong principal Class.");
      continue;
    }
    if([pluginBundle.principalClass instancesRespondToSelector:NSSelectorFromString(@"initWithPluginManager:")]) {
      NSLog(@"Plugin uses old interface. Update plugin to use initWithPluginHost: instead of initWithPluginManager:!");
    }
    
    MPPlugin *plugin = [[pluginBundle.principalClass alloc] initWithPluginHost:self];
    if(plugin) {
      NSLog(@"Loaded plugin instance %@", pluginBundle.principalClass);
      [[NSNotificationCenter defaultCenter] postNotificationName:MPPluginHostWillLoadPlugin
                                                          object:self
                                                        userInfo:@{ MPPluginHostPluginBundleIdentifiyerKey : plugin.identifier }];
      [self.mutablePlugins addObject:plugin];
      [[NSNotificationCenter defaultCenter] postNotificationName:MPPluginHostDidLoadPlugin
                                                          object:self
                                                        userInfo:@{ MPPluginHostPluginBundleIdentifiyerKey : plugin.identifier }];
    }
    else {
      NSLog(@"Unable to create instance of plugin class %@", pluginBundle.principalClass);
    }
  }
}

- (BOOL)_validateUniqueBundle:(NSBundle *)bundle {
  for(MPPlugin *plugin in self.mutablePlugins) {
    NSBundle *pluginBundle = [NSBundle bundleForClass:plugin.class];
    if([pluginBundle.bundleIdentifier isEqualToString:bundle.bundleIdentifier]) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)_validURL:(NSURL *)url {
  return (NSOrderedSame == [url.pathExtension compare:kMPPluginFileExtension options:NSCaseInsensitiveSearch]);
}

- (BOOL)_validateClass:(Class)class {
  return [class isSubclassOfClass:[MPPlugin class]];
}

/* Code by Jedda Wignall<jedda@jedda.me> http://jedda.me/2012/03/verifying-plugin-bundles-using-code-signing/ */
- (BOOL)_validSignature:(NSURL *)url {
  if(!url.path) {
    return NO;
  }
  
  if(self.loadUnsecurePlugins) {
    return YES;
  }
  
  NSTask * task = [[NSTask alloc] init];
  NSPipe * pipe = [NSPipe pipe];
  NSArray* args = @[ @"--verify",
                     /*[NSString stringWithFormat:@"-R=anchor = \"%@\"", [[NSBundle mainBundle] pathForResource:@"BlargsoftCodeCA" ofType:@"cer"]],*/
                     url.path ];
  task.launchPath = @"/usr/bin/codesign";
  task.standardOutput = pipe;
  task.standardError = pipe;
  task.arguments = args;
  [task launch];
  [task waitUntilExit];
  
  if(task.terminationStatus == 0) {
    return YES;
  }
  NSString *pluginPath = url.path ? url.path : @"<emptyPath>";
  NSString * taskString = [[NSString alloc] initWithData:pipe.fileHandleForReading.readDataToEndOfFile encoding:NSASCIIStringEncoding];
  if ([taskString rangeOfString:@"modified"].length > 0 || [taskString rangeOfString:@"a sealed resource is missing or invalid"].length > 0) {
    // The plugin has been modified or resources removed since being signed. You probably don't want to load this.
    NSLog(@"Plugin %@ modified - not loaded", pluginPath); // log a real error here
  }
  else if ([taskString rangeOfString:@"failed to satisfy"].length > 0) {
    // The plugin is missing resources since being signed. Don't load.
    // throw an error
    NSLog(@"Plugin %@ not signed by correct CA - not loaded", pluginPath); // log a real error here
  }
  else if ([taskString rangeOfString:@"not signed at all"].length > 0) {
    // The plugin was not code signed at all. Don't load.
    NSLog(@"Plugin %@ not signed at all - don't load.", pluginPath); // log a real error here
  }
  else {
    NSLog(@"Unkown CodeSign Error!");
  }
  
  return NO;
}


@end
