//
//  MPPluginManager.m
//  MacPass
//
//  Created by Michael Starke on 16/07/15.
//  Copyright (c) 2015 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginManager.h"

#import "MPDocument.h"
#import "MPPlugin.h"
#import "NSApplication+MPAdditions.h"
#import "MPSettingsHelper.h"

#import "KeePassKit/KeePassKit.h"


NSString *const MPPluginManagerWillLoadPlugin = @"com.hicknhack.macpass.MPPluginManagerWillLoadPlugin";
NSString *const MPPluginManagerDidLoadPlugin = @"comt.hicknhack.macpass.MPPluginManagerDidLoadPlugin";
NSString *const MPPluginManagerWillUnloadPlugin = @"com.hicknhack.macpass.MPPluginManagerWillUnloadPlugin";
NSString *const MPPluginManagerDidUnloadPlugin = @"com.hicknhack.macpass.MPPluginManagerDidUnloadPlugin";

NSString *const MPPluginManagerPluginBundleIdentifiyerKey = @"MPPluginManagerPluginBundleIdentifiyerKey";


@interface MPPluginManager ()

@property (strong) NSMutableArray<MPPlugin __kindof *> *mutablePlugins;
@property (nonatomic) BOOL loadUnsecurePlugins;

@end

@implementation MPPluginManager

+ (NSSet *)keyPathsForValuesAffectingPlugins {
  return [NSSet setWithObject:NSStringFromSelector(@selector(mutablePlugins))];
}

+ (instancetype)sharedManager {
  static MPPluginManager *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[MPPluginManager alloc] _init];
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

- (void)setLoadUnsecurePlugins:(BOOL)loadUnsecurePlugins {
  if(_loadUnsecurePlugins != loadUnsecurePlugins) {
    _loadUnsecurePlugins = loadUnsecurePlugins;
    [self _loadPlugins];
  }
}

- (NSArray<MPPlugin *> *)plugins {
  return [self.mutablePlugins copy];
}

- (NSArray *)filteredEntriesUsingBlock:(NodeMatchBlock)matchBlock {
  NSArray *currentDocuments = [[NSDocumentController sharedDocumentController] documents];
  NSMutableArray *entries = [[NSMutableArray alloc] initWithCapacity:200];
  for(MPDocument *document in currentDocuments) {
    if(document.tree) {
      [entries addObjectsFromArray:document.tree.allEntries];
    }
  }
  NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) { return matchBlock(evaluatedObject); }];
  return [[NSArray alloc] initWithArray:[entries filteredArrayUsingPredicate:predicate] copyItems:YES];
}

- (NSArray *)filteredGroupsUsingBlock:(NodeMatchBlock)matchBlock {
  NSAssert(NO, @"Not implemented");
  return nil;
}

- (void)_unloadPlugins {
  /* TODO Notofications for UI */
  NSMutableArray *bundles = [[NSMutableArray alloc] initWithCapacity:self.mutablePlugins.count];
  for(MPPlugin *plugin in self.mutablePlugins) {
    NSBundle *pluginBundle = [NSBundle bundleForClass:plugin.class];
    if(pluginBundle) {
      [bundles addObject:pluginBundle];
      [[NSNotificationCenter defaultCenter] postNotificationName:MPPluginManagerWillUnloadPlugin object:self userInfo:@{ MPPluginManagerPluginBundleIdentifiyerKey : plugin.identifier}];
    }
  }
  [self.mutablePlugins removeAllObjects];
  for(NSBundle *bundle in bundles) {
    [bundle unload];
    NSString *identifiery = bundle.bundleIdentifier ? bundle.bundleIdentifier : @"unknown";
    [[NSNotificationCenter defaultCenter] postNotificationName:MPPluginManagerDidUnloadPlugin object:self userInfo:@{ MPPluginManagerPluginBundleIdentifiyerKey : identifiery }];
  }
}

- (void)_loadPlugins {
  /* unload all plugins just to be sure */
  [self _unloadPlugins];
  NSURL *dir = [NSApp applicationSupportDirectoryURL:YES];
  NSError *error;
  NSArray *contentURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:dir
                                                       includingPropertiesForKeys:@[]
                                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                            error:&error];
  if(!contentURLs) {
    NSLog(@"Error while trying to locate Plugins: %@", error.localizedDescription);
  }
  for(NSURL *pluginURL in contentURLs) {
    
    if(![self _validURL:pluginURL]) {
      continue;
    }
    
    if(![self _validSignature:pluginURL]) {
      continue;
    }
    
    NSBundle *pluginBundle = [NSBundle bundleWithURL:pluginURL];
    if(!pluginBundle) {
      continue;
    }
    
    if(![self _validateClass:pluginBundle.principalClass]) {
      continue;
    }
    MPPlugin *plugin = [[pluginBundle.principalClass alloc] initWithPluginManager:self];
    if(plugin) {
      [[NSNotificationCenter defaultCenter] postNotificationName:MPPluginManagerWillLoadPlugin object:self userInfo:@{ MPPluginManagerPluginBundleIdentifiyerKey : plugin.identifier }];
      [self.mutablePlugins addObject:plugin];
      [[NSNotificationCenter defaultCenter] postNotificationName:MPPluginManagerDidLoadPlugin object:self userInfo:@{ MPPluginManagerPluginBundleIdentifiyerKey : plugin.identifier }];
    }
  }
}

- (BOOL)_validURL:(NSURL *)url {
  return (NSOrderedSame == [url.pathExtension compare:kMPPluginFileExtension options:NSCaseInsensitiveSearch]);
}

- (BOOL)_validateClass:(Class)class {
  return ([class isSubclassOfClass:[MPPlugin class]]);
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
