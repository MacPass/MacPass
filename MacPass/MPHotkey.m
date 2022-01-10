//
//  MPHotkey.m
//  MacPass
//
//  Created by George Snow on 7.1.2022.
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

#import "MPHotkey.h"
#import "MPSettingsHelper.h"

#import "MPPluginHost.h"
#import "MPPlugin.h"

#import "MPDocument.h"
#import "MPDocumentWindowController.h"
#import "MPDocumentController.h"

#import "NSApplication+MPAdditions.h"
#import "NSUserNotification+MPAdditions.h"

#import "DDHotKeyCenter.h"
#import "DDHotKey+MacPassAdditions.h"

#import "KeePassKit/KeePassKit.h"
#import <Carbon/Carbon.h>

@interface MPHotkeyDaemon ()

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, copy) NSData *hotKeyData;
@property (strong) DDHotKey *registredHotKey;

@end

@implementation MPHotkeyDaemon

#pragma mark -
#pragma mark Lifecylce

static MPHotkeyDaemon *_sharedInstance;

+ (instancetype)hotkeyDaemon {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[MPHotkeyDaemon alloc] _init];
  });
  return _sharedInstance;
}

- (instancetype)init {
  return nil;
}

- (instancetype)_init {
  NSAssert(_sharedInstance == nil, @"Multiple initializations not allowed on singleton");
  self = [super init];
  if (self) {
    _enabled = NO;
    //_userActionRequested = NSDate.distantPast.timeIntervalSinceReferenceDate;
    [self bind:NSStringFromSelector(@selector(enabled))
      toObject:NSUserDefaultsController.sharedUserDefaultsController
   withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyShowOrHideMacPass]
       options:nil];
    
    [self bind:NSStringFromSelector(@selector(hotKeyData))
      toObject:NSUserDefaultsController.sharedUserDefaultsController
   withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyShowHideKeyDataKey]
       options:nil];


    
    
  }
  return self;
}

- (void)dealloc {

  [self unbind:NSStringFromSelector(@selector(enabled))];
  [self unbind:NSStringFromSelector(@selector(hotKeyData))];
}

#pragma mark -
#pragma mark Properties

- (void)setEnabled:(BOOL)enabled {
  if(_enabled != enabled) {
    _enabled = enabled;
    self.enabled ? [self _registerHotKey] : [self _unregisterHotKey];
  }
}

- (void)setHotKeyData:(NSData *)hotKeyData {
  if(![_hotKeyData isEqualToData:hotKeyData]) {
    [self _unregisterHotKey];
    _hotKeyData = [hotKeyData copy];
    if(self.enabled) {
      [self _registerHotKey];
    }
  }
}

#pragma mark -
#pragma mark Hotkey Registration
- (void)_registerHotKey {
  if(!self.hotKeyData) {
    return;
  }
  __weak MPHotkeyDaemon *welf = self;
  DDHotKeyTask aTask = ^(NSEvent *event) {
    [welf _didPressHotKey];
  };
  self.registredHotKey = [[DDHotKeyCenter sharedHotKeyCenter] registerHotKey:[DDHotKey hotKeyWithKeyData:self.hotKeyData task:aTask]];
}

- (void)_unregisterHotKey {
  if(self.registredHotKey) {
    [[DDHotKeyCenter sharedHotKeyCenter] unregisterHotKey:self.registredHotKey];
    self.registredHotKey = nil;
  }
}

#pragma mark -
#pragma mark Show/Hide Invocation


- (void)_didPressHotKey {

  bool mpActive = [NSApp isActive];
  BOOL focusSearchAfterHotkey = [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyFocusSearchAfterHotkey];
  
  if(mpActive) {
      [NSApplication.sharedApplication hide:nil];
    }
  else {
      [NSApplication.sharedApplication activateIgnoringOtherApps:YES];
      

      
      if(focusSearchAfterHotkey) {
        [self _focusSearchAfterHotkey];
    }
      
  }
  
}
- (void)_focusSearchAfterHotkey {

  NSArray *documents = [NSDocumentController sharedDocumentController].documents;
  NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
    MPDocument *document = evaluatedObject;
    return !document.encrypted;}];
  NSArray *unlockedDocuments = [documents filteredArrayUsingPredicate:filterPredicate];
  [unlockedDocuments makeObjectsPerformSelector:@selector(performCustomSearch:)];

  
}
@end
