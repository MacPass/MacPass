//
//  MPPastBoardController.m
//  MacPass
//
//  Created by Michael Starke on 02.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPasteBoardController.h"
#import "MPSettingsHelper.h"

/* Notifications */
NSString *const MPPasteBoardControllerDidCopyObjects    = @"com.hicknhack.macpass.MPPasteBoardControllerDidCopyObjects";
NSString *const MPPasteBoardControllerDidClearClipboard = @"com.hicknhack.macpass.MPPasteBoardControllerDidClearClipboard";

@interface MPPasteBoardController ()

@property (assign) BOOL isEmpty;

@end

@implementation MPPasteBoardController

+ (MPPasteBoardController *)defaultController {
  static MPPasteBoardController* sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[MPPasteBoardController alloc] init];
  });
  return sharedInstance;
}

- (id)init {
  self = [super init];
  if (self) {
    _isEmpty = YES;
    [self _setupBindings];
    [self _updateNotifications];
  }
  return self;
}

- (void)dealloc
{
  if(_clearPasteboardOnShutdown) {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
  }
}

- (void)_updateNotifications {
  if(self.clearPasteboardOnShutdown) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_clearPasteboardContents) name:NSApplicationWillTerminateNotification object:nil];
  }
  else {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
  }
}

- (void)setClearTimeout:(NSTimeInterval)clearTimeout {
  if(_clearTimeout != clearTimeout) {
    if(clearTimeout > 0) {
      [self _clearPasteboardContents];
    }
    _clearTimeout = clearTimeout;
  }
}

- (void)setClearPasteboardOnShutdown:(BOOL)clearPasteboardOnShutdown {
  if(_clearPasteboardOnShutdown != clearPasteboardOnShutdown ) {
    _clearPasteboardOnShutdown = !_clearPasteboardOnShutdown;
    [self _updateNotifications];
  }
}

- (void)copyObjects:(NSArray *)objects {
  /* Should we save the old content ?*/
  [[NSPasteboard generalPasteboard] clearContents];
  [[NSPasteboard generalPasteboard] writeObjects:objects];
  self.isEmpty = NO;
  if(self.clearTimeout != 0) {
    [[NSNotificationCenter defaultCenter] postNotificationName:MPPasteBoardControllerDidCopyObjects object:self];
    [self performSelector:@selector(_clearPasteboardContents) withObject:nil afterDelay:self.clearTimeout];
  }
}

- (void)_clearPasteboardContents {
  /* Only clear stuff we might have put there */
  if(!self.isEmpty) {
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSNotificationCenter defaultCenter] postNotificationName:MPPasteBoardControllerDidClearClipboard object:self];
  }
  self.isEmpty = YES;
}

- (void)_setupBindings {
  NSUserDefaultsController *userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
  NSString *clearOnShutdownKeyPath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyClearPasteboardOnQuit];
  [self bind:NSStringFromSelector(@selector(clearPasteboardOnShutdown)) toObject:userDefaultsController withKeyPath:clearOnShutdownKeyPath options:nil];
  NSString *clearTimoutKeyPath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyPasteboardClearTimeout];
  [self bind:NSStringFromSelector(@selector(clearTimeout)) toObject:userDefaultsController withKeyPath:clearTimoutKeyPath options:nil];
}

@end
