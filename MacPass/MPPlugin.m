//
//  MPPlugin.m
//  MacPass
//
//  Created by Michael Starke on 11/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import "MPPlugin.h"
#import "MPPluginManager.h"

NSString *const kMPPluginFileExtension = @"mpplugin";

@implementation MPPlugin

+ (instancetype)pluginWithBundleURL:(NSURL *)url pluginManager:(MPPluginManager *)manager {
  if(![self _validURL:url]) {
    return nil;
  }
  NSBundle *pluginBundle = [NSBundle bundleWithURL:url];
  if(!pluginBundle) {
    return nil;
  }
  if(![self _validateClass:pluginBundle.principalClass]) {
    return nil;
  }
  return [[pluginBundle.principalClass alloc] initWithPluginManager:manager];
}

- (instancetype)initWithPluginManager:(MPPluginManager *)manager {
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

+ (BOOL)_validURL:(NSURL *)url {
  return (NSOrderedSame == [url.pathExtension compare:kMPPluginFileExtension options:NSCaseInsensitiveSearch]);
}

+ (BOOL)_validateClass:(Class)class {
  return ([class isSubclassOfClass:[MPPlugin class]]);
}

/* Code by Jedda Wignall<jedda@jedda.me> http://jedda.me/2012/03/verifying-plugin-bundles-using-code-signing/ */
+ (BOOL)_validSignature:(NSURL *)url {
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
  NSString * taskString = [[NSString alloc] initWithData:pipe.fileHandleForReading.readDataToEndOfFile encoding:NSASCIIStringEncoding];
  if ([taskString rangeOfString:@"modified"].length > 0 || [taskString rangeOfString:@"a sealed resource is missing or invalid"].length > 0) {
    // The plugin has been modified or resources removed since being signed. You probably don't want to load this.
    NSLog(@"Plugin modified - not loaded"); // log a real error here
  }
  else if ([taskString rangeOfString:@"failed to satisfy"].length > 0) {
    // The plugin is missing resources since being signed. Don't load.
    // throw an error
    NSLog(@"Plugin not signed by correct CA - not loaded"); // log a real error here
  }
  else if ([taskString rangeOfString:@"not signed at all"].length > 0) {
    // The plugin was not code signed at all. Don't load.
    NSLog(@"Plugin not signed at all - don't load."); // log a real error here
  }
  else {
    // Some other codesign error
  }
  return NO;
}

@end
