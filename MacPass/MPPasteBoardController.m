//
//  MPPastBoardController.m
//  MacPass
//
//  Created by Michael Starke on 02.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPasteBoardController.h"
#import "MPSettingsHelper.h"

@interface MPPasteBoardController ()

@property (assign) BOOL isEmpty;

- (void)_clearPasteboardContents;
- (void)_setupBindings;
- (void)_updateNotifications;

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
  [super dealloc];
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
  [[NSPasteboard generalPasteboard] clearContents];
  [[NSPasteboard generalPasteboard] writeObjects:objects];
  self.isEmpty = NO;
  [self performSelector:@selector(_clearPasteboardContents) withObject:nil afterDelay:self.clearTimeout];
}

- (void)_clearPasteboardContents {
  /* Only clear stuff we might have put there */
  if(!self.isEmpty) {
    [[NSPasteboard generalPasteboard] clearContents];
  }
  self.isEmpty = YES;
}

- (void)_setupBindings {
  NSUserDefaultsController *userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
  NSString *clearOnShutdownKeyPath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyClearPasteboardOnQuit];
  NSString *clearTimoutKeyPath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyPasteboardClearTimeout];
  [self bind:@"clearPasteboardOnShutdown" toObject:userDefaultsController withKeyPath:clearOnShutdownKeyPath options:nil];
  [self bind:@"clearTimeout" toObject:userDefaultsController withKeyPath:clearTimoutKeyPath options:nil];
}

@end
