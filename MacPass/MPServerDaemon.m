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
#import "MPIconHelper.h"
#import "MPConnection.h"
#import "MPServerRequestHandler.h"

@interface MPServerDaemon () {
@private
  HTTPServer *server;
  NSStatusItem *statusItem;
}

@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, assign) BOOL showStatusItem;

@end

@implementation MPServerDaemon

- (id)init {
  self = [super init];
  if (self) {
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    NSString *enableServerKeyPath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyEnableHttpServer];
    NSString *showItemKeyPath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyShowMenuItem];
    [self bind:@"isEnabled" toObject:defaultsController withKeyPath:enableServerKeyPath options:nil];
    [self bind:@"showStatusItem" toObject:defaultsController withKeyPath:showItemKeyPath options:nil];
  }
  return self;
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
    // setup menu item
  }
  else {
    /* Do not let the resource linger around */
    server = nil;
  }
  [self _updateStatusItem];
}


- (void)setShowStatusItem:(BOOL)showStatusItem {
  if(_showStatusItem != showStatusItem) {
    _showStatusItem = showStatusItem;
    [self _updateStatusItem];
  }
}

- (void)_updateStatusItem {
  if(_isEnabled && _showStatusItem) {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setImage:[MPIconHelper icon:MPIconServer ]];
  }
  else if(statusItem) {
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
    statusItem = nil;
  }
}

- (void)_setupServer {
  NSAssert(server == nil, @"Server should be nil");
  server = [[HTTPServer alloc] init];
  [server setConnectionClass:[MPConnection class]];
  [server setInterface:@"localhost"];
  NSInteger port = [[NSUserDefaults standardUserDefaults] integerForKey:kMPSettingsKeyHttpPort];
  [server setPort:port];

}

@end
