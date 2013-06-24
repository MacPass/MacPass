//
//  MPLockDaemon.m
//  MacPass
//
//  Created by Michael Starke on 16.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPLockDaemon.h"
#import "MPSettingsHelper.h"
#import "MPAppDelegate.h"

NSString *const MPShouldLockDatabaseNotification = @"com.hicknhack.macpass.MPShouldLockDatabaseNotification";

@interface MPLockDaemon () {
  NSTimer *idleCheckTimer;
}

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
    NSString *idleTimeOutKey = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyIdleLockTimeOut];
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    [self bind:@"lockOnSleep" toObject:defaultsController withKeyPath:lockOnSleepKey options:nil];
    [self bind:@"idleLockTime" toObject:defaultsController withKeyPath:idleTimeOutKey options:nil];
  }
  return self;
}

- (void)dealloc
{
  /* Notifications */
  [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
  
  /* Timer */
  [idleCheckTimer invalidate];
  [idleCheckTimer release];
  
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
      [idleCheckTimer invalidate];
      [idleCheckTimer release];
      idleCheckTimer = nil;
    }
    else {
      if( idleCheckTimer ) {
        NSAssert([idleCheckTimer isValid], @"Timer needs to be valid");
        [idleCheckTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_idleLockTime ]];
        return; // Done
      }
      /* Create new timer and schedule it with runloop */
      idleCheckTimer = [[NSTimer timerWithTimeInterval:_idleLockTime target:self selector:@selector(_checkIdleTime:) userInfo:nil repeats:YES] retain];
      [[NSRunLoop mainRunLoop] addTimer:idleCheckTimer forMode:NSDefaultRunLoopMode];
    }
  }
}

- (void)_willSleepNotification:(NSNotification *)notification {
  [[NSApp delegate] lockAllDocuments];
}

- (void)_checkIdleTime:(NSTimer *)timer {
  CFTimeInterval interval = CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateCombinedSessionState,kCGAnyInputEventType);
  if(interval >= _idleLockTime) {
    [[NSApp delegate] lockAllDocuments];
    /* Reset the timer to full intervall */
    [idleCheckTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_idleLockTime]];
  }
  else {
    [idleCheckTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:(_idleLockTime - interval) ]];
  }
}

@end
