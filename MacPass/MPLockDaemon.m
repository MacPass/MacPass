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

@interface MPLockDaemon ()

@property (nonatomic,assign) BOOL lockOnSleep;
@property (nonatomic,assign) NSUInteger idleLockTime;
@property (nonatomic,strong) id eventHandler;
@property (nonatomic,strong) NSTimer *idleCheckTimer;
@property (assign) NSTimeInterval lastLocalEventTime;

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
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    [self bind:NSStringFromSelector(@selector(lockOnSleep)) toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyLockOnSleep] options:nil];
    [self bind:NSStringFromSelector(@selector(idleLockTime)) toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyIdleLockTimeOut] options:nil];
  }
  return self;
}

- (void)dealloc {
  /* Notifications */
  [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
  
  /* Timer */
  [NSEvent removeMonitor:self.eventHandler];
  
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
      [self _stopIdleChecking];
    }
    else {
      [self _updateOrStartIdleChecking];
    }
  }
}

- (void)_willSleepNotification:(NSNotification *)notification {
  [(MPAppDelegate *)[NSApp delegate] lockAllDocuments];
}

- (void)_checkIdleTime:(NSTimer *)timer {
  if(timer != self.idleCheckTimer) {
    return; // Wrong timer?!
  }
  NSTimeInterval currentInterval = ([NSDate timeIntervalSinceReferenceDate] - self.lastLocalEventTime);
  if(self.idleLockTime < currentInterval) {
    [(MPAppDelegate *)[NSApp delegate] lockAllDocuments];
    /* Reset the timer to full interval */
    [self.idleCheckTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_idleLockTime]];
  }
  else {
    [self.idleCheckTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:(_idleLockTime - currentInterval)]];
  }
}

- (void)_stopIdleChecking {
  [self.idleCheckTimer invalidate];
  self.idleCheckTimer = nil;
  [NSEvent removeMonitor:self.eventHandler];
  self.eventHandler = nil;
}

- (void)_updateOrStartIdleChecking {
  /* update or create Timer */
  if( self.idleCheckTimer ) {
    NSAssert([self.idleCheckTimer isValid], @"Timer needs to be valid");
    [self.idleCheckTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.idleLockTime ]];
  }
  else {
    self.idleCheckTimer = [NSTimer timerWithTimeInterval:self.idleLockTime target:self selector:@selector(_checkIdleTime:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.idleCheckTimer forMode:NSDefaultRunLoopMode];
  }
  /* Create event handler if necessary */
  if(self.eventHandler) {
    return;
  }
  MPLockDaemon __weak *welf = self;
  self.eventHandler = [NSEvent addLocalMonitorForEventsMatchingMask:NSAnyEventMask handler:^NSEvent *(NSEvent *theEvent) {
    welf.lastLocalEventTime = [NSDate timeIntervalSinceReferenceDate];
    return theEvent;
  }];
}

@end
