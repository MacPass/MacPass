//
//  MPServerSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
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

#import "MPIntegrationSettingsController.h"
#import "MPSettingsHelper.h"
#import "MPIconHelper.h"

#import "DDHotKeyCenter.h"
#import "DDHotKey+MacPassAdditions.h"
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
  NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
  NSString *enableGlobalAutotypeKeyPath = [MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyEnableGlobalAutotype];
  NSString *quicklookKeyPath = [MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyEnableQuicklookPreview];
  [self.enableGlobalAutotypeCheckBox bind:NSValueBinding toObject:defaultsController withKeyPath:enableGlobalAutotypeKeyPath options:nil];
  [self.enableQuicklookCheckBox bind:NSValueBinding toObject:defaultsController withKeyPath:quicklookKeyPath options:nil];
  [self.hotKeyTextField bind:NSEnabledBinding toObject:defaultsController withKeyPath:enableGlobalAutotypeKeyPath options:nil];
  self.hotKeyTextField.delegate = self;
  
  [self.matchTitleCheckBox bind:NSValueBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyAutotypeMatchTitle ] options:nil];
  [self.matchURLCheckBox bind:NSValueBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyAutotypeMatchURL] options:nil];
  [self.matchHostCheckBox bind:NSValueBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyAutotypeMatchHost] options:nil];
  [self.matchTagsCheckBox bind:NSValueBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyAutotypeMatchTags] options:nil];
  
  [self.sendCommandForControlCheckBox bind:NSValueBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeySendCommandForControlKey] options:nil];
  
  [self _showWarning:NO];
}

- (void)willShowTab {
  _hotKey = [DDHotKey hotKeyWithKeyData:[[NSUserDefaults standardUserDefaults] dataForKey:kMPSettingsKeyGlobalAutotypeKeyDataKey]];
  /* Change any invalid hotkeys to valid ones? */
  self.hotKeyTextField.hotKey = self.hotKey;
}

#pragma mark -
#pragma mark Properties
- (void)setHotKey:(DDHotKey *)hotKey {
  if([self.hotKey isEqual:hotKey]) {
    return; // Nothing of interest has changed;
  }
  _hotKey = hotKey;
  [[NSUserDefaults standardUserDefaults] setObject:self.hotKey.keyData forKey:kMPSettingsKeyGlobalAutotypeKeyDataKey];
}

#pragma mark -
#pragma mark NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)obj {
  BOOL validHotKey = self.hotKeyTextField.hotKey.valid;
  [self _showWarning:!validHotKey];
  if(validHotKey) {
    self.hotKey = self.hotKeyTextField.hotKey;
  }
}

- (void)_showWarning:(BOOL)show {
  self.hotkeyWarningTextField.hidden = !show;
}

@end
