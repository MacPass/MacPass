//
//  MPPastBoardController.m
//  MacPass
//
//  Created by Michael Starke on 02.03.13.
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
    [NSNotificationCenter.defaultCenter removeObserver:self];
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
  for (NSPasteboardItem *item in NSPasteboard.generalPasteboard.pasteboardItems) {
    NSPasteboardItem *newItem = [[NSPasteboardItem alloc] init];
    for (NSString *type in item.types) {
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
    [NSPasteboard.generalPasteboard clearContents];
    [NSPasteboard.generalPasteboard writeObjects:self.stashedObjects];
    self.stashedObjects = nil;
    self.isEmpty = YES;
  }
}

- (void)copyObjects:(NSArray<id<NSPasteboardWriting>> *)objects {
  [self copyObjectsWithoutTimeout:objects];
  if(self.clearTimeout != 0) {
    [NSNotificationCenter.defaultCenter postNotificationName:MPPasteBoardControllerDidCopyObjects object:self];
    [self performSelector:@selector(_clearPasteboardContents) withObject:nil afterDelay:self.clearTimeout];
  }
}

- (void)copyObjectsWithoutTimeout:(NSArray<id<NSPasteboardWriting>> *)objects {
  [NSPasteboard.generalPasteboard clearContents];
  [NSPasteboard.generalPasteboard writeObjects:objects];
  self.isEmpty = NO;
}

- (void)_clearPasteboardContents {
  /* Only clear stuff we might have put there */
  if(!self.isEmpty) {
    [[NSPasteboard generalPasteboard] clearContents];
    [NSNotificationCenter.defaultCenter postNotificationName:MPPasteBoardControllerDidClearClipboard object:self];
  }
  self.isEmpty = YES;
}

- (void)_updateNotifications {
  if(self.clearPasteboardOnShutdown) {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_clearPasteboardContents) name:NSApplicationWillTerminateNotification object:nil];
  }
  else {
    [NSNotificationCenter.defaultCenter removeObserver:self];
  }
}

- (void)_setupBindings {
  [self bind:NSStringFromSelector(@selector(clearPasteboardOnShutdown))
    toObject:NSUserDefaultsController.sharedUserDefaultsController
 withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyClearPasteboardOnQuit]
     options:nil];
  
  [self bind:NSStringFromSelector(@selector(clearTimeout))
    toObject:NSUserDefaultsController.sharedUserDefaultsController
 withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyPasteboardClearTimeout]
     options:nil];
}

@end
