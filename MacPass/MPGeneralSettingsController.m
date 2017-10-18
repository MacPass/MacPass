//
//  MPGeneralSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 23.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
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

#import "MPGeneralSettingsController.h"
#import "MPSettingsHelper.h"
#import "MPIconHelper.h"

NSString *const MPGeneralSetingsIdentifier = @"GeneralSettingsTab";

@implementation MPGeneralSettingsController

- (NSString *)nibName {
  return @"GeneralSettings";
}

- (NSString *)identifier {
  return MPGeneralSetingsIdentifier;
}

- (NSImage *)image {
  return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)label {
  return NSLocalizedString(@"GENERAL_SETTINGS", @"General Settings Label");
}

- (void)viewDidLoad {
  NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];

  [self.clearPasteboardOnQuitCheckButton bind:NSValueBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyClearPasteboardOnQuit] options:nil];
  [self.clearPasteboardTimeoutPopup bind:NSSelectedTagBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyPasteboardClearTimeout] options:nil];
  [self.lockOnSleepCheckButton bind:NSValueBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyLockOnSleep] options:nil];
  [self.lockOnLogoutCheckButton bind:NSValueBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingskeyLockOnLogout] options:nil];
  [self.idleTimeOutPopup bind:NSSelectedTagBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyIdleLockTimeOut] options:nil];
  [self.reopenLastDatabase bind:NSValueBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyReopenLastDatabaseOnLaunch] options:nil];
  [self.rememberKeyFileCheckButton bind:NSValueBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyRememberKeyFilesForDatabases] options:nil];
  [self.createUntitledOnActivation setState:NSOffState]; //kMPSettingsKeyOpenEmptyDatabaseOnLaunch

  /* File Change Strategy Menu */
  NSDictionary *fileChangeStragegyDict = @{ @(MPFileChangeStrategyAsk) : NSLocalizedString(@"FILE_CHANGE_STRATEGY_ASK", @""),
                                            @(MPFileChangeStrategyUseOther) : NSLocalizedString(@"FILE_CHANGE_STRATEGY_USE_OTHER", @""),
                                            @(MPFileChangeStrategyKeepMine) : NSLocalizedString(@"FILE_CHANGE_STRATEGY_KEEP_MINE", @""),
                                            @(MPFileChangeStrategyMerge) : NSLocalizedString(@"FILE_CHANGE_STRATEGY_MERGE", @""),
                                            };
  [self.fileChangeStrategyPopup.menu removeAllItems];
  for(NSNumber *key in fileChangeStragegyDict) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:fileChangeStragegyDict[key] action:NULL keyEquivalent:@""];
    item.tag = key.integerValue;
    [self.fileChangeStrategyPopup.menu addItem:item];
  }
  [self.fileChangeStrategyPopup bind:NSSelectedTagBinding toObject:defaultsController withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyFileChangeStrategy] options:nil];
  
}
@end
