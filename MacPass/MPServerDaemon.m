//
//  MPServerDaemon.m
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPServerDaemon.h"
#import "MPSettingsHelper.h"
#import "HTTPServer.h"

@interface MPServerDaemon () {
@private
  HTTPServer *server;
}

@property (nonatomic, assign) BOOL isEnabled;

@end

@implementation MPServerDaemon

- (id)init {
  self = [super init];
  if (self) {
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    NSString *defaultsKeyPath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyEnableHttpServer];
    [self bind:@"isEnabled" toObject:defaultsController withKeyPath:defaultsKeyPath options:nil];
  }
  return self;
}

- (void)dealloc
{
  [server release];
  [super dealloc];
}

- (void)setIsEnabled:(BOOL)enabled {
  if(_isEnabled == enabled) {
    return; // NO changes
  }
  _isEnabled = enabled;
  if(enabled) {
    if(!server) {
      [self _setupServer];
    }
    NSError *error= nil;
    if(![server start:&error]) {     
      [NSApp presentError:error];
    }
  }
  else {
    /* Do not let the resource linger around */
    [server release];
    server = nil;
  }
}

- (void)_setupServer {
  NSAssert(server == nil, @"Server should be nil");
  server = [[HTTPServer alloc] init];
  [server setInterface:@"localhost"];
  NSInteger port = [[NSUserDefaults standardUserDefaults] integerForKey:kMPSettingsKeyHttpPort];
  [server setPort:port];
}

@end
