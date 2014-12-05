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
@property (nonatomic, strong) NSMutableArray *stashedObjects;

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

- (void)dealloc {
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

- (void)setClearPasteboardOnShutdown:(BOOL)clearPasteboardOnShutdown {
  if(_clearPasteboardOnShutdown != clearPasteboardOnShutdown ) {
    _clearPasteboardOnShutdown = !_clearPasteboardOnShutdown;
    [self _updateNotifications];
  }
}

- (void)stashObjects {
  self.stashedObjects = [NSMutableArray array];
  for (NSPasteboardItem *item in [[NSPasteboard generalPasteboard] pasteboardItems]) {
    NSPasteboardItem *newItem = [[NSPasteboardItem alloc] init];
    for (NSString *type in [item types]) {
      NSData *data = [[item dataForType:type] mutableCopy];
      if (data) {
        [newItem setData:data forType:type];
      }
    }
    [self.stashedObjects addObject:newItem];
  }
}

- (void)restoreObjects {
  if (self.stashedObjects) {
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:self.stashedObjects];
    self.stashedObjects = nil;
    self.isEmpty = YES;
  }
}

- (void)copyObjects:(NSArray *)objects {
  [self copyObjectsWithoutTimeout:objects];
  if(self.clearTimeout != 0) {
    [[NSNotificationCenter defaultCenter] postNotificationName:MPPasteBoardControllerDidCopyObjects object:self];
    [self performSelector:@selector(_clearPasteboardContents) withObject:nil afterDelay:self.clearTimeout];
  }
}

- (void)copyObjectsWithoutTimeout:(NSArray *)objects
{
  [[NSPasteboard generalPasteboard] clearContents];
  [[NSPasteboard generalPasteboard] writeObjects:objects];
  self.isEmpty = NO;
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
  NSString *clearOnShutdownKeyPath = [MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyClearPasteboardOnQuit];
  NSString *clearTimoutKeyPath = [MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyPasteboardClearTimeout];
  
  [self bind:NSStringFromSelector(@selector(clearPasteboardOnShutdown))
    toObject:userDefaultsController
 withKeyPath:clearOnShutdownKeyPath
     options:nil];
  
  [self bind:NSStringFromSelector(@selector(clearTimeout))
    toObject:userDefaultsController
 withKeyPath:clearTimoutKeyPath
     options:nil];
}

@end
