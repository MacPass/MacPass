//
//  MPLockDaemon.m
//  MacPass
//
//  Created by Michael Starke on 16.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPLockDaemon.h"
#import "MPSettingsHelper.h"

NSString *const MPShouldLockDatabaseNotification = @"com.hicknhack.macpass.MPShouldLockDatabaseNotification";

@interface MPLockDaemon ()

@property (nonatomic,assign) BOOL lockOnSleep;
@property (nonatomic,assign) NSUInteger idleLockTime;

@end

@implementation MPLockDaemon

+ (MPLockDaemon *)sharedInstance {
  static id sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[MPLockDaemon alloc] init];
  });
  return sharedInstance;
}

- (id)init {
  self = [super init];
  if (self) {
    NSString *lockOnSleepKey = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyLockOnSleep];
    NSString *idleTimeOutKey = [NSString stringWithFormat:@"values.%@", kMPSEttingsKeyIdleLockTimeOut];
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    [self bind:@"lockOnSleep" toObject:defaultsController withKeyPath:lockOnSleepKey options:nil];
    [self bind:@"idleLockTime" toObject:defaultsController withKeyPath:idleTimeOutKey options:nil];
  }
  return self;
}

- (void)dealloc
{
  [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
  [super dealloc];
}

- (void)setLockOnSleep:(BOOL)lockOnSleep {
  if(_lockOnSleep != lockOnSleep) {
    _lockOnSleep = lockOnSleep;
    NSNotificationCenter *notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    if(_lockOnSleep) {
      [notificationCenter addObserver:self selector:@selector(_willSleepNotification:) name:NSWorkspaceWillSleepNotification object:nil];
    }
    else {
      [notificationCenter removeObserver:self];
    }
  }
}

- (void)setIdleLockTime:(NSUInteger)idleLockTime {
  if(_idleLockTime != idleLockTime) {
    _idleLockTime = idleLockTime;
    if(_idleLockTime == 0) {
      // disable
    }
    else {
      // update timer
    }
  }
}

- (void)_willSleepNotification:(NSNotification *)notification {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPShouldLockDatabaseNotification object:self];
}

@end
