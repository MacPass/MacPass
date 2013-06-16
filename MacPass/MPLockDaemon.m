//
//  MPLockDaemon.m
//  MacPass
//
//  Created by Michael Starke on 16.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPLockDaemon.h"

NSString *const MPShouldLockDatabaseNotification = @"com.hicknhack.macpass.MPShouldLockDatabaseNotification";

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
    NSNotificationCenter *notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    [notificationCenter addObserver:self selector:@selector(_willSleepNotification:) name:NSWorkspaceWillSleepNotification object:nil];
  }
  return self;
}

- (void)dealloc
{
  [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
  [super dealloc];
}


- (void)_willSleepNotification:(NSNotification *)notification {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPShouldLockDatabaseNotification object:self];
}

@end
