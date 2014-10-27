//
//  MPServerSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPIntegrationSettingsController.h"
#import "MPSettingsHelper.h"
#import "MPIconHelper.h"

#import "DDHotKeyCenter.h"
#import "DDHotKey+Keydata.h"
#import "DDHotKeyTextField.h"

@interface MPIntegrationSettingsController ()

@property (nonatomic, strong) DDHotKey *hotKey;

@end

@implementation MPIntegrationSettingsController

- (NSString *)nibName {
  return @"IntegrationSettings";
}

- (NSString *)identifier {
  return @"Integration";
}

- (NSImage *)image {
  return [NSImage imageNamed:NSImageNameComputer];
}

- (NSString *)label {
  return NSLocalizedString(@"INTEGRATION_SETTINGS", "");
}

- (void)awakeFromNib {
  self.hotKey = [DDHotKey defaultHotKey];
  NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
  NSString *serverKeyPath = [MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyEnableHttpServer];
  NSString *enableGlobalAutotypeKeyPath = [MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyEnableGlobalAutotype];
  NSString *quicklookKeyPath = [MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyEnableQuicklookPreview];
  [self.enableServerCheckbutton bind:NSValueBinding toObject:defaultsController withKeyPath:serverKeyPath options:nil];
  [self.enableServerCheckbutton setEnabled:NO];
  [self.enableGlobalAutotypeCheckbutton bind:NSValueBinding toObject:defaultsController withKeyPath:enableGlobalAutotypeKeyPath options:nil];
  [self.enableQuicklookCheckbutton bind:NSValueBinding toObject:defaultsController withKeyPath:quicklookKeyPath options:nil];
  [self.hotKeyTextField bind:NSEnabledBinding toObject:defaultsController withKeyPath:enableGlobalAutotypeKeyPath options:nil];
  self.hotKeyTextField.hotKey = self.hotKey;
  self.hotKeyTextField.delegate = self;
}

- (void)setHotKey:(DDHotKey *)hotKey {
  static NSData *defaultHotKeyData = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    defaultHotKeyData = [[DDHotKey defaultHotKey] keyData];
  });
  NSData *newData = [hotKey keyData];
  if(![newData isEqualToData:defaultHotKeyData]) {
    [[NSUserDefaults standardUserDefaults] setObject:newData forKey:kMPSettingsKeyGlobalAutotypeKeyDataKey];
  }
  _hotKey = hotKey;
}

- (void)controlTextDidChange:(NSNotification *)obj {
  NSLog(@"controlTextDidChange:");
}

@end
