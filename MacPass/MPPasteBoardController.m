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
#import "MPOverlayWindowController.h"

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
      /* mutable copy to ensure actual deep copy */
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
    /* cancel old timer */
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_clearPasteboardContents) object:nil];
    /* setup new timer */
    [self performSelector:@selector(_clearPasteboardContents) withObject:nil afterDelay:self.clearTimeout];
  }
}

- (void)copyObjectsWithoutTimeout:(NSArray<id<NSPasteboardWriting>> *)objects {
  if(@available(macOS 10.12, *)) {
    NSPasteboardContentsOptions options = [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyPreventUniversalClipboard] ? NSPasteboardContentsCurrentHostOnly : 0;
    [NSPasteboard.generalPasteboard prepareForNewContentsWithOptions:options];
  }
  else {
    [NSPasteboard.generalPasteboard clearContents];
  }
  [NSPasteboard.generalPasteboard writeObjects:objects];
  self.isEmpty = NO;
}

- (void)copyObjects:(NSArray<id<NSPasteboardWriting>> *)objects overlayInfo:(MPPasteboardOverlayInfoType)overlayInfoType name:(NSString *)name atView:(NSView *)view{
  if(!objects) {
    return;
  }
  [MPPasteBoardController.defaultController copyObjects:objects];
  NSImage *infoImage = nil;
  NSString *infoText = nil;
  switch(overlayInfoType) {
    case MPPasteboardOverlayInfoPassword:
      infoImage = [NSBundle.mainBundle imageForResource:@"00_PasswordTemplate"];
      infoText = NSLocalizedString(@"COPIED_PASSWORD", @"Password was copied to the pasteboard");
      break;
      
    case MPPasteboardOverlayInfoURL:
      infoImage = [NSBundle.mainBundle imageForResource:@"01_PackageNetworkTemplate"];
      infoText = NSLocalizedString(@"COPIED_URL", @"URL was copied to the pasteboard");
      break;
      
    case MPPasteboardOverlayInfoUsername:
      infoImage = [NSBundle.mainBundle imageForResource:@"09_IdentityTemplate"];
      infoText = NSLocalizedString(@"COPIED_USERNAME", @"Username was copied to the pasteboard");
      break;
      
    case MPPasteboardOverlayInfoCustom:
      infoImage = [NSBundle.mainBundle imageForResource:@"00_PasswordTemplate"];
      infoText = [NSString stringWithFormat:NSLocalizedString(@"COPIED_FIELD_%@", "Field name that was copied to the pasteboard"), name];
      break;
      
    case MPPasteboardOverlayInfoReference:
      infoImage = [NSBundle.mainBundle imageForResource:@"04_KlipperTemplate"];
      infoText = name;
      break;
      
  }
  [MPOverlayWindowController.sharedController displayOverlayImage:infoImage label:infoText atView:view];
  
  BOOL hide = [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyHideAfterCopyToClipboard];
  if(hide) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(400 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
      [NSApplication.sharedApplication hide:nil];
    });
  }
}

- (void)_clearPasteboardContents {
  /* Only clear stuff we might have put there */
  if(!self.isEmpty) {
    [NSPasteboard.generalPasteboard clearContents];
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
