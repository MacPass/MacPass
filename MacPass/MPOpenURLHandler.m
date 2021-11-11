//
//  MPOpenURLHandler.m
//  MacPass
//
//  Created by Michael Starke on 11.11.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//

#import "MPOpenURLHandler.h"

#import "MPSettingsHelper.h"

@implementation MPOpenURLHandler

static MPOpenURLHandler *_defaultInstance;

+ (MPOpenURLHandler *)sharedHandler {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _defaultInstance = [[MPOpenURLHandler alloc] _init];
  });
  return _defaultInstance;
}

- (instancetype)init {
  return _defaultInstance;
}

- (NSArray<NSString *>*)privateBrowsingArgsForBundleId:(NSString *)bundleId {
  
  static NSDictionary *privateBrowsingArgs;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    privateBrowsingArgs = @{ @"com.google.Chrome" : @[@"--incognito"] };
  });
  return privateBrowsingArgs[bundleId];
}


- (instancetype)_init {
  NSAssert(_defaultInstance == nil, @"Multiple instances of MPLockDaemon not allowed!");
  self = [super init];
  return self;
}

- (void)openURL:(NSString *)url {
  NSURL *webURL = [NSURL URLWithString:url];
  NSString *scheme = webURL.scheme;
  if(!scheme) {
    webURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", url]];
  }
  
  NSString *browserBundleID = [NSUserDefaults.standardUserDefaults stringForKey:kMPSettingsKeyBrowserBundleId];
  NSURL *browserApplicationURL = browserBundleID ? [NSWorkspace.sharedWorkspace URLForApplicationWithBundleIdentifier:browserBundleID] : nil;
  BOOL openedURL = NO;
  
  if(browserApplicationURL) {
    NSRunningApplication *urlOpeningApplication = [NSWorkspace.sharedWorkspace openURLs:@[webURL] withApplicationAtURL:browserApplicationURL options:NSWorkspaceLaunchDefault configuration:@{} error:nil];
    openedURL = nil != urlOpeningApplication;
  }
  
  if(!openedURL) {
    openedURL = [NSWorkspace.sharedWorkspace openURL:webURL];
  }
  if(!openedURL) {
    NSLog(@"Unable to open URL %@", webURL);
  }
}

- (BOOL)supportsPrivateBrowsingForBundleId:(NSString *)bundleId {
  return (nil != [self privateBrowsingArgsForBundleId:bundleId]);
}

- (NSArray<NSString *>*)_launchArgumentsForBrowserBundleID:(NSString *)bundleId {
  BOOL usePrivateBrowsing = [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyUsePrivateBrowsingWhenOpeningURLs];
  NSMutableArray<NSString *> *args = [[NSMutableArray alloc] init];
  if(usePrivateBrowsing) {
    NSArray<NSString *>* privateArgs = [self privateBrowsingArgsForBundleId:bundleId];
    if(privateArgs) {
      [args addObjectsFromArray:privateArgs];
    }
  }
  return [args copy];
}


@end
