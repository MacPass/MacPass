//
//  MPServerDaemon.m
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPServerDaemon.h"
#import "MPSettingsHelper.h"
#import "MPIconHelper.h"
#import "MPServerRequestHandling.h"
#import "NSString+MPPasswordCreation.h"
#import "MPDocument.h"
#import "KPKGroup.h"
#import "MPDocumentQueryService.h"
#import "KPHServer.h"

@interface MPServerDaemon () {
@private
  KPHServer *server;
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
    NSString *enableServerKeyPath = [MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyEnableHttpServer];
    NSString *showItemKeyPath = [MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyShowMenuItem];
    [self bind:NSStringFromSelector(@selector(isEnabled)) toObject:defaultsController withKeyPath:enableServerKeyPath options:nil];
    [self bind:NSStringFromSelector(@selector(showStatusItem)) toObject:defaultsController withKeyPath:showItemKeyPath options:nil];
  }
  return self;
}

- (void)setIsEnabled:(BOOL)enabled {
  if(_isEnabled == enabled)
    return; // NO changes

  _isEnabled = enabled;
  if(enabled) {
    
    if(!server) {
      server = [[KPHServer alloc] init];
      server.delegate = [MPDocumentQueryService sharedService];
    }
    
    if(![server startWithPort:[[NSUserDefaults standardUserDefaults] integerForKey:kMPSettingsKeyHttpPort]])
      NSLog(@"Failed to start KeePassHttp server");
  }
  else {
    if (server)
      [server stop];
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

@end
