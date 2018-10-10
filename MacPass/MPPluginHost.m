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
#import "MPPlugin_Private.h"
#import "MPPluginConstants.h"
#import "MPPluginEntryActionContext.h"
#import "MPPluginRepository.h"
#import "MPPluginRepositoryItem.h"

#import "NSApplication+MPAdditions.h"
#import "MPSettingsHelper.h"

#import "NSError+Messages.h"

#import "KeePassKit/KeePassKit.h"


NSString *const MPPluginHostWillLoadPlugin = @"com.hicknhack.macpass.MPPluginHostWillLoadPlugin";
NSString *const MPPluginHostDidLoadPlugin = @"comt.hicknhack.macpass.MPPluginHostDidLoadPlugin";

NSString *const MPPluginHostPluginBundleIdentifiyerKey = @"MPPluginHostPluginBundleIdentifiyerKey";

@interface MPPluginHost ()
@property (strong) NSMutableArray<MPPlugin __kindof *> *mutablePlugins;
@property (strong) NSMutableArray<NSString *> *entryActionPluginIdentifiers;
@property (strong) NSMutableArray<NSString *> *customAttributePluginIdentifiers;


@property (nonatomic) BOOL loadUnsecurePlugins;
@property (copy) NSArray<NSString *> *disabledPlugins;

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
    _disabledPlugins = [NSUserDefaults.standardUserDefaults arrayForKey:kMPSettingsKeyLoadUnsecurePlugins];
    _loadUnsecurePlugins = [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyLoadUnsecurePlugins];
    _entryActionPluginIdentifiers = [[NSMutableArray alloc] init];
    _customAttributePluginIdentifiers = [[NSMutableArray alloc] init];
    
    [self bind:NSStringFromSelector(@selector(loadUnsecurePlugins))
      toObject:NSUserDefaultsController.sharedUserDefaultsController
   withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyLoadUnsecurePlugins]
       options:nil];
    [self bind:NSStringFromSelector(@selector(disabledPlugins))
     toObject:NSUserDefaultsController.sharedUserDefaultsController
   withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyDisabledPlugins]
       options:nil];
  }
  return self;
}

- (NSString *)version {
  NSString *version = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
  return version;
}

- (NSArray<MPPlugin *> *)plugins {
  return [self.mutablePlugins copy];
}

- (BOOL)installPluginAtURL:(NSURL *)url error:(NSError *__autoreleasing *)error {
  if(![self _isValidPluginURL:url]) {
    if(error) {
      *error = [NSError errorWithCode:MPErrorInvalidPlugin description:NSLocalizedString(@"ERROR_INVALID_PLUGIN", @"Error description given when adding an invalid plugin")];
    }
    return NO;
  }
  NSString *fileName;
  if(![url getResourceValue:&fileName forKey:NSURLNameKey error:error]) {
    return NO;
  }
  NSURL *appSupportURL = [NSApp applicationSupportDirectoryURL:YES];
  NSURL *destinationURL = [appSupportURL URLByAppendingPathComponent:fileName];
  return [NSFileManager.defaultManager moveItemAtURL:url toURL:destinationURL error:error];
}

- (BOOL)uninstallPlugin:(MPPlugin *)plugin error:(NSError *__autoreleasing *)error {
  return [NSFileManager.defaultManager trashItemAtURL:plugin.bundle.bundleURL resultingItemURL:nil error:error];
}

- (void)disablePlugin:(MPPlugin *)plugin {
}

- (void)enablePlugin:(MPPlugin *)plugin {
}


#pragma mark - Plugin Loading

- (void)loadPlugins {
  [MPPluginRepository.defaultRepository fetchRepositoryDataCompletionHandler:^(NSArray<MPPluginRepositoryItem *> * _Nonnull availablePlugins) {
    [self _loadPlugins:availablePlugins];
  }];
}

- (void)_loadPlugins:(NSArray<MPPluginRepositoryItem *> *)availablePlugins {
  NSURL *appSupportDir = [NSApp applicationSupportDirectoryURL:YES];
  NSError *error;
  NSLog(@"Looking for external plugins at %@.", appSupportDir.path);
  NSArray *externalPluginsURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:appSupportDir
                                                               includingPropertiesForKeys:@[]
                                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                    error:&error];
  
  NSLog(@"Looking for internal plugins");
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
    if(![self _isValidPluginURL:pluginURL]) {
      NSLog(@"Skipping %@. No valid plugin file.", pluginURL.path);
      continue;
    }

    NSBundle *pluginBundle = [NSBundle bundleWithURL:pluginURL];
    if(!pluginBundle) {
      NSLog(@"Could not access plugin bundle %@", pluginURL.path);
      continue;
    }
    
    if(![self _isSignedPluginURL:pluginURL]) {
      if(self.loadUnsecurePlugins) {
        NSLog(@"Loading unsecure Plugin at %@.", pluginURL.path);
      }
      else {
        [self _addPluginForBundle:pluginBundle error:NSLocalizedString(@"PLUGIN_ERROR_UNSECURE_PLUGIN", "Error for a plugin that was not signed properly")];
        continue;
      }
    }
    
    NSError *error;
    if(![pluginBundle preflightAndReturnError:&error]) {
      NSLog(@"Preflight Error %@ %@", error.localizedDescription, error.localizedFailureReason );
      [self _addPluginForBundle:pluginBundle error:error.localizedDescription];
      continue;
    };
    
    if([self _validateUniqueBundle:pluginBundle]) {
      NSLog(@"Plugin %@ already loaded!", pluginBundle.bundleIdentifier);
      continue;
    }
    
    if(![self _isCompatiblePluginBundle:pluginBundle avaiablePlugins:availablePlugins ]) {
      [self _addPluginForBundle:pluginBundle error:NSLocalizedString(@"PLUGIN_ERROR_HOST_VERSION_NOT_SUPPORTED", "Plugin is not with this version of MacPass")];
      continue;
    }
    
    if(![pluginBundle loadAndReturnError:&error]) {
      NSLog(@"Bundle Loading Error %@ %@", error.localizedDescription, error.localizedFailureReason);
      [self _addPluginForBundle:pluginBundle error:error.localizedDescription];
      continue;
    }
    
    if(![self _isValidPluginClass:pluginBundle.principalClass]) {
      NSLog(@"Wrong principal Class.");
      [self _addPluginForBundle:pluginBundle error:NSLocalizedString(@"PLUGIN_ERROR_WRONG_PRINCIPAL_CLASS", "Plugin specifies the wrong principla class!".)];
      continue;
    }
    
    IMP defaultImp = [MPPlugin.class instanceMethodForSelector:@selector(initWithPluginManager:)];
    IMP pluginImp = [pluginBundle.principalClass instanceMethodForSelector:@selector(initWithPluginManager:)];
    
    MPPlugin *plugin;
    if(defaultImp != pluginImp) {
      NSLog(@"Plugin uses old interface. Update plugin to use initWithPluginHost: instead of initWithPluginManager:!");
      plugin = [[pluginBundle.principalClass alloc] initWithPluginManager:self];
    }
    else {
      plugin = [[pluginBundle.principalClass alloc] initWithPluginHost:self];
    }

    if(plugin) {
      NSLog(@"Loaded plugin instance %@", pluginBundle.principalClass);
      [[NSNotificationCenter defaultCenter] postNotificationName:MPPluginHostWillLoadPlugin
                                                          object:self
                                                        userInfo:@{ MPPluginHostPluginBundleIdentifiyerKey : plugin.identifier }];
      [self _addPlugin:plugin];
      [[NSNotificationCenter defaultCenter] postNotificationName:MPPluginHostDidLoadPlugin
                                                          object:self
                                                        userInfo:@{ MPPluginHostPluginBundleIdentifiyerKey : plugin.identifier }];
    }
    else {
      NSLog(@"Unable to create instance of plugin class %@", pluginBundle.principalClass);
      [self _addPluginForBundle:pluginBundle error:NSLocalizedString(@"PLUGIN_ERROR_INTILIZATION_FAILED", "The plugin could not be initalized".)];
    }
  }
}

- (void)_addPluginForBundle:(NSBundle *)bundle error:(NSString *)errorMessage {
  MPPlugin *plugin = [[MPPlugin alloc] initWithPluginHost:self];
  plugin.bundle = bundle;
  plugin.enabled = NO;
  plugin.errorMessage = errorMessage;
  [self _addPlugin:plugin];
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

- (BOOL)_isCompatiblePluginBundle:(NSBundle *)bundle avaiablePlugins:(NSArray<MPPluginRepositoryItem *> *)availablePlugins {
  MPPluginRepositoryItem *repoItem;
  for(MPPluginRepositoryItem *item in availablePlugins) {
    if([item.bundleIdentifier isEqualToString:bundle.bundleIdentifier]) {
      repoItem = item;
    }
  }
  NSString *shortVersion = bundle.infoDictionary[@"CFBundleShortVersionString"];
  return [repoItem isPluginVersion:shortVersion compatibleWithHost:self];
}

- (BOOL)_isValidPluginURL:(NSURL *)url {
  return (NSOrderedSame == [url.pathExtension compare:MPPluginFileExtension options:NSCaseInsensitiveSearch]);
}

- (BOOL)_isValidPluginClass:(Class)class {
  return [class isSubclassOfClass:[MPPlugin class]];
}

/* Code by Jedda Wignall<jedda@jedda.me> http://jedda.me/2012/03/verifying-plugin-bundles-using-code-signing/ */
- (BOOL)_isSignedPluginURL:(NSURL *)url {
  if(!url.path) {
    return NO;
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
    NSLog(@"Plugin %@ modified", pluginPath); // log a real error here
  }
  else if ([taskString rangeOfString:@"failed to satisfy"].length > 0) {
    // The plugin is missing resources since being signed. Don't load.
    // throw an error
    NSLog(@"Plugin %@ not signed by correct CA", pluginPath); // log a real error here
  }
  else if ([taskString rangeOfString:@"not signed at all"].length > 0) {
    // The plugin was not code signed at all. Don't load.
    NSLog(@"Plugin %@ not signed at all.", pluginPath); // log a real error here
  }
  else {
    NSLog(@"Unkown CodeSign Error!");
  }
  
  return NO;
}

- (void)_addPlugin:(MPPlugin *)plugin {
  [self.mutablePlugins addObject:plugin];
  if([plugin conformsToProtocol:@protocol(MPEntryActionPlugin)]) {
    NSAssert(![self.entryActionPluginIdentifiers containsObject:plugin.identifier], @"Internal inconsitency. Duplicate bundle identifier used %@!", plugin.identifier);
    [self.entryActionPluginIdentifiers addObject:plugin.identifier];
  }
  if([plugin conformsToProtocol:@protocol(MPCustomAttributePlugin)]) {
    NSAssert(![self.customAttributePluginIdentifiers containsObject:plugin.identifier], @"Internal inconsitency. Duplicate bundle identifier used %@!", plugin.identifier);
    [self.customAttributePluginIdentifiers addObject:plugin.identifier];
  }
}

- (MPPlugin *)_pluginWithIdentifier:(NSString *)bundleIdentifier {
  for(MPPlugin *plugin in self.mutablePlugins) {
    if([plugin.identifier isEqualToString:bundleIdentifier]) {
      return plugin;
    }
  }
  return nil;
}

#pragma mark Action Plugins

- (NSArray *)avilableMenuItemsForEntries:(NSArray<KPKEntry *> *)entries {
  NSMutableArray *items = [[NSMutableArray alloc] init];
  for(NSString *identifier in self.entryActionPluginIdentifiers) {
    MPPlugin<MPEntryActionPlugin> *plugin = (MPPlugin<MPEntryActionPlugin> *)[self _pluginWithIdentifier:identifier];
    if(plugin) {
      NSArray <NSMenuItem *> *tmpItems = [plugin menuItemsForEntries:entries];
      for(NSMenuItem *item in tmpItems) {
        item.representedObject = [[MPPluginEntryActionContext alloc] initWithPlugin:plugin entries:entries];
        item.target = self;
        item.action = @selector(_performEntryAction:);
      }
      [items addObjectsFromArray:tmpItems];
    }
  }
  return [items copy];
}

- (void)_performEntryAction:(id)sender {
  if(![sender isKindOfClass:NSMenuItem.class]) {
    return;
  }
  NSMenuItem *item = sender;
  MPPluginEntryActionContext *context = item.representedObject;
  [context.plugin performActionForMenuItem:item withEntries:context.entries];
}



@end
