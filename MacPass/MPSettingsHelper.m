//
//  MPSettingsHelper.m
//  MacPass
//
//  Created by Michael Starke on 30.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPSettingsHelper.h"

NSString *const kMPSettingsKeyPasteboardClearTimeout = @"ClipboardClearTimeout";
NSString *const kMPSettingsKeyClearPasteboardOnQuit  = @"ClearClipboardOnQuit";
NSString *const kMPSettingsKeyDoubleClickURLToLaunch  = @"DoubleClickURLToLaunch";
NSString *const kMPSettingsKeyOpenEmptyDatabaseOnLaunch = @"OpenEmptyDatabaseOnLaunch";
NSString *const kMPSettingsKeyReopenLastDatabaseOnLaunch = @"ReopenLastDatabaseOnLaunch";
NSString *const kMPSettingsKeyHttpPort =@"HttpPort";
NSString *const kMPSettingsKeyEnableHttpServer = @"EnableHttpServer";
NSString *const kMPSettingsKeyShowMenuItem = @"ShowMenuItem";
NSString *const kMPSettingsKeyLockOnSleep = @"LockOnSleep";
NSString *const kMPSettingsKeyIdleLockTimeOut = @"IdleLockTimeOut";
NSString *const kMPSettingsKeyShowInspector = @"ShowInspector";

NSString *const kMPSettingsKeyLegacyHideTitle = @"LegacyHideTitle";
NSString *const kMPSettingsKeyLegacyHideUsername = @"LegacyHideUsername ";
NSString *const kMPSettingsKeyLegacyHidePassword = @"LegacyHidePassword";
NSString *const kMPSettingsKeyLegacyHideNotes = @"LegacyHideNotes";
NSString *const kMPSettingsKeyLegacyHideURL = @"LegacyHideURL";

NSString *const kMPSettingsKeyLastDatabasePath = @"MPLastDatabasePath";
NSString *const kMPSettingsKeyFilesForDatabases = @"MPKeyFilesForDatabases";
NSString *const kMPSettingsKeyRememberKeyFilesForDatabases = @"kMPSettingsKeyRememberKeyFilesForDatabases";

@implementation MPSettingsHelper

+ (void)setupDefaults {
  [[NSUserDefaults standardUserDefaults] registerDefaults:[self _standardDefaults]];
}

+ (NSString *)defaultControllerPathForKey:(NSString *)key {
  return [NSString stringWithFormat:@"values.%@", key];
}

+ (NSDictionary *)_standardDefaults {
  return @{
           kMPSettingsKeyShowInspector: @YES, // Show the Inspector by default
           kMPSettingsKeyPasteboardClearTimeout: @30, // 30 seconds
           kMPSettingsKeyClearPasteboardOnQuit: @YES,
           kMPSettingsKeyDoubleClickURLToLaunch: @NO,
           kMPSettingsKeyOpenEmptyDatabaseOnLaunch: @NO,
           kMPSettingsKeyReopenLastDatabaseOnLaunch: @YES,
           kMPSettingsKeyHttpPort: @19455,
           kMPSettingsKeyEnableHttpServer: @NO,
           kMPSettingsKeyShowMenuItem: @YES,
           kMPSettingsKeyLockOnSleep: @YES,
           kMPSettingsKeyIdleLockTimeOut: @0, // 5 minutes
           kMPSettingsKeyLegacyHideNotes: @NO,
           kMPSettingsKeyLegacyHidePassword: @YES,
           kMPSettingsKeyLegacyHideTitle: @NO,
           kMPSettingsKeyLegacyHideURL: @NO,
           kMPSettingsKeyLegacyHideUsername: @NO,
           kMPSettingsKeyRememberKeyFilesForDatabases: @NO
           };
}

@end
