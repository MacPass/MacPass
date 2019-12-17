//
//  MPLockDaemon.m
//  MacPass
//
//  Created by Michael Starke on 16.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "MPLockDaemon.h"
#import "MPSettingsHelper.h"
#import "MPAppDelegate.h"

@interface MPLockDaemon ()

@property (nonatomic,assign) BOOL lockOnSleep;
@property (nonatomic,assign) BOOL lockOnLogout;
@property (nonatomic,assign) BOOL lockOnScreenSleep;
@property (nonatomic,assign) NSUInteger idleLockTime;
@property (nonatomic,strong) id localEventHandler;
@property (nonatomic,strong) NSTimer *idleCheckTimer;
@property (assign) NSTimeInterval lastLocalEventTime;

@end

@implementation MPLockDaemon

static MPLockDaemon *_sharedInstance;

+ (instancetype)defaultDaemon {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[MPLockDaemon alloc] _init];
  });
  return _sharedInstance;
}

- (instancetype)init {
  return nil;
}

- (instancetype)_init {
  NSAssert(_sharedInstance == nil, @"Multiple instances of MPLockDaemon not allowed!");
  self = [super init];
  if (self) {
    NSUserDefaultsController *defaultsController = NSUserDefaultsController.sharedUserDefaultsController;
    [self bind:NSStringFromSelector(@selector(lockOnSleep)) toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyLockOnSleep] options:nil];
    [self bind:NSStringFromSelector(@selector(idleLockTime)) toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyIdleLockTimeOut] options:nil];
    [self bind:NSStringFromSelector(@selector(lockOnLogout)) toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingskeyLockOnLogout] options:nil];
    [self bind:NSStringFromSelector(@selector(lockOnScreenSleep)) toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingskeyLockOnScreenSleep] options:nil];
  }
  return self;
}

- (void)dealloc {
  /* Notifications */
  [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self];
  
  /* Timer */
  [NSEvent removeMonitor:self.localEventHandler];
}

- (void)setLockOnLogout:(BOOL)lockOnLogout {
  if(_lockOnLogout != lockOnLogout) {
    _lockOnLogout = lockOnLogout;
    if(_lockOnLogout) {
      [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self selector:@selector(_willLogOutNotification:) name:NSWorkspaceSessionDidResignActiveNotification object:nil];
    }
    else {
      [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self name:@"" object:nil];
    }
  }
}

- (void)setLockOnSleep:(BOOL)lockOnSleep {
  if(_lockOnSleep != lockOnSleep) {
    _lockOnSleep = lockOnSleep;
    if(_lockOnSleep) {
      [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self selector:@selector(_willSleepNotification:) name:NSWorkspaceWillSleepNotification object:nil];
    }
    else {
      [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self name:NSWorkspaceWillSleepNotification object:nil];
    }
  }
}

- (void)setLockOnScreenSleep:(BOOL)lockOnScreenSleep {
  if(_lockOnScreenSleep != lockOnScreenSleep) {
    _lockOnScreenSleep = lockOnScreenSleep;
    if(_lockOnScreenSleep) {
      [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self selector:@selector(_willScreenSleepNotification:) name:NSWorkspaceScreensDidSleepNotification object:nil];
    }
    else {
      [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self name:NSWorkspaceScreensDidSleepNotification object:nil];
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

- (void)_willLogOutNotification:(NSNotification *)notification {
  [((MPAppDelegate *)NSApp.delegate) lockAllDocuments];
}
- (void)_willSleepNotification:(NSNotification *)notification {
  [((MPAppDelegate *)NSApp.delegate) lockAllDocuments];
}
- (void)_willScreenSleepNotification:(NSNotification *)notification {
  [((MPAppDelegate *)NSApp.delegate) lockAllDocuments];
}

- (void)_checkIdleTime:(NSTimer *)timer {
  if(timer != self.idleCheckTimer) {
    return; // Wrong timer?!
  }
  NSTimeInterval currentInterval = (NSDate.timeIntervalSinceReferenceDate - self.lastLocalEventTime);
  if(self.idleLockTime < currentInterval) {
    [((MPAppDelegate *)NSApp.delegate) lockAllDocuments];
    /* Reset the timer to full interval */
    self.idleCheckTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:_idleLockTime];
  }
  else {
    self.idleCheckTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:(_idleLockTime - currentInterval)];
  }
}

- (void)_stopIdleChecking {
  [self.idleCheckTimer invalidate];
  self.idleCheckTimer = nil;
  [NSEvent removeMonitor:self.localEventHandler];
  self.localEventHandler = nil;
}

- (void)_updateOrStartIdleChecking {
  /* update or create Timer */
  if( self.idleCheckTimer ) {
    NSAssert([self.idleCheckTimer isValid], @"Timer needs to be valid");
    self.idleCheckTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.idleLockTime];
  }
  else {
    self.idleCheckTimer = [NSTimer timerWithTimeInterval:self.idleLockTime target:self selector:@selector(_checkIdleTime:) userInfo:nil repeats:YES];
    [NSRunLoop.mainRunLoop addTimer:self.idleCheckTimer forMode:NSDefaultRunLoopMode];
  }
  /* Create event handler if necessary */
  if(!self.localEventHandler) {
    self.localEventHandler = [NSEvent addLocalMonitorForEventsMatchingMask:NSAnyEventMask handler:^NSEvent *(NSEvent *theEvent) {
      self.lastLocalEventTime = NSDate.timeIntervalSinceReferenceDate;
      return theEvent;
    }];
  } 
}

@end
