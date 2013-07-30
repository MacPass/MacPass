//
//  MPGeneralSettingsController.m
//  MacPass
//
//  Created by Michael Starke on 23.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPGeneralSettingsController.h"
#import "MPSettingsHelper.h"
#import "MPIconHelper.h"

NSString *const MPGeneralSetingsIdentifier = @"GeneralSettingsTab";

@implementation MPGeneralSettingsController

- (id)init {
  return [self initWithNibName:@"GeneralSettings" bundle:[NSBundle mainBundle]];
}

- (NSString *)identifier {
  return MPGeneralSetingsIdentifier;
}

- (NSImage *)image {
  return [MPIconHelper icon:MPIconWarning];
}

- (NSString *)label {
  return NSLocalizedString(@"GENERAL_SETTINGS", @"General Settings Label");
}

- (void)didLoadView {
  NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
  NSString *reopenLastFilePath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyReopenLastDatabaseOnLaunch];
  //NSString *createUntitledOnActivatePaht = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyOpenEmptyDatabaseOnLaunch];
  NSString *clearPasteboardKeyPath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyClearPasteboardOnQuit];
  NSString *doubleClickURLToLaunchKeyPath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyDoubleClickURLToLaunch];
  NSString *clearPasteboardTimeOutKeyPath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyPasteboardClearTimeout];
  NSString *idleTimeOutKeyPath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyIdleLockTimeOut];
  NSString *lockOnSleepKeyPath = [NSString stringWithFormat:@"values.%@", kMPSettingsKeyLockOnSleep];
  [self.clearPasteboardOnQuitCheckButton bind:NSValueBinding toObject:defaultsController withKeyPath:clearPasteboardKeyPath options:nil];
  [self.doubleClickURLToLaunchCheckButton bind:NSValueBinding toObject:defaultsController withKeyPath:doubleClickURLToLaunchKeyPath options:nil];
  [self.clearPasteboardTimeoutPopup bind:NSSelectedTagBinding toObject:defaultsController withKeyPath:clearPasteboardTimeOutKeyPath options:nil];
  [self.lockOnSleepCheckButton bind:NSValueBinding toObject:defaultsController withKeyPath:lockOnSleepKeyPath options:nil];
  [self.idleTimeOutPopup bind:NSSelectedTagBinding toObject:defaultsController withKeyPath:idleTimeOutKeyPath options:nil];
  [self.reopenLastDatabase bind:NSValueBinding toObject:defaultsController withKeyPath:reopenLastFilePath options:nil];
  [self.createUntitledOnActivation setState:NSOffState];
  //[self.createUntitledOnActivation bind:NSValueBinding toObject:defaultsController withKeyPath:createUntitledOnActivatePaht options:nil];
}
@end
