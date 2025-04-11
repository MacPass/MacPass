//
//  MPSecurityPreferencesController.m
//  MacPass
//
//  Created by Michael Starke on 11.04.25.
//  Copyright © 2025 HicknHack Software GmbH. All rights reserved.
//

#import "MPSecurityPreferencesController.h"
#import "MPSettingsHelper.h"

@interface MPSecurityPreferencesController ()

@end

@implementation MPSecurityPreferencesController

- (NSString *)identifier {
  return @"SecurityPreferences";
}

- (NSImage *)image {
  return [NSImage imageNamed:NSImageNameCaution];
}

- (NSString *)label {
  return NSLocalizedString(@"SECURITY_PREFERENCES", @"Security Settings Label");
}

- (void)viewDidLoad {
  [self.clearPasteboardOnQuitCheckButton bind:NSValueBinding
                                     toObject:NSUserDefaultsController.sharedUserDefaultsController
                                  withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyClearPasteboardOnQuit]
                                      options:nil];
  [self.clearPasteboardTimeoutPopup bind:NSSelectedTagBinding
                                toObject:NSUserDefaultsController.sharedUserDefaultsController
                             withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyPasteboardClearTimeout]
                                 options:nil];
  [self.preventUniversalClipboardSupportCheckButton bind:NSValueBinding
                                                toObject:NSUserDefaultsController.sharedUserDefaultsController
                                             withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyPreventUniversalClipboard]
                                                 options:nil];
  [self.lockOnSleepCheckButton bind:NSValueBinding
                           toObject:NSUserDefaultsController.sharedUserDefaultsController
                        withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyLockOnSleep]
                            options:nil];
  [self.lockOnLogoutCheckButton bind:NSValueBinding
                            toObject:NSUserDefaultsController.sharedUserDefaultsController
                         withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingskeyLockOnLogout]
                             options:nil];
  [self.lockOnScreenSleepCheckButton bind:NSValueBinding
                                 toObject:NSUserDefaultsController.sharedUserDefaultsController
                              withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingskeyLockOnScreenSleep]
                                  options:nil];
  [self.idleTimeOutPopup bind:NSSelectedTagBinding
                     toObject:NSUserDefaultsController.sharedUserDefaultsController
                  withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyIdleLockTimeOut]
                      options:nil];
  [self.rememberKeyFileCheckButton bind:NSValueBinding
                               toObject:NSUserDefaultsController.sharedUserDefaultsController
                            withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyRememberKeyFilesForDatabases]
                                options:nil];
  [self.allowScreenshotsCheckButton bind:NSValueBinding
                                toObject:NSUserDefaultsController.sharedUserDefaultsController
                             withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyAllowScreenshots]
                                 options:nil];
}
@end
