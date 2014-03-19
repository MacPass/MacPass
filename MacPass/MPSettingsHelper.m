//
//  MPSettingsHelper.m
//  MacPass
//
//  Created by Michael Starke on 30.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPSettingsHelper.h"

NSString *const kMPSettingsKeyPasteboardClearTimeout        = @"ClipboardClearTimeout";
NSString *const kMPSettingsKeyClearPasteboardOnQuit         = @"ClearClipboardOnQuit";
NSString *const kMPSettingsKeyDoubleClickURLToLaunch        = @"DoubleClickURLToLaunch";
NSString *const kMPSettingsKeyBrowserBundleId               = @"BrowserBundleId";
NSString *const kMPSettingsKeyOpenEmptyDatabaseOnLaunch     = @"OpenEmptyDatabaseOnLaunch";
NSString *const kMPSettingsKeyReopenLastDatabaseOnLaunch    = @"ReopenLastDatabaseOnLaunch";
NSString *const kMPSettingsKeyHttpPort                      = @"HttpPort";
NSString *const kMPSettingsKeyEnableHttpServer              = @"EnableHttpServer";
NSString *const kMPSettingsKeyShowMenuItem                  = @"ShowMenuItem";
NSString *const kMPSettingsKeyLockOnSleep                   = @"LockOnSleep";
NSString *const kMPSettingsKeyIdleLockTimeOut               = @"IdleLockTimeOut";
NSString *const kMPSettingsKeyShowInspector                 = @"ShowInspector";
NSString *const kMPSettingsKeyEntryTableSortDescriptors     = @"EntryTableSortDescriptors";

NSString *const kMPSettingsKeyLegacyHideTitle               = @"LegacyHideTitle";
NSString *const kMPSettingsKeyLegacyHideUsername            = @"LegacyHideUsername ";
NSString *const kMPSettingsKeyLegacyHidePassword            = @"LegacyHidePassword";
NSString *const kMPSettingsKeyLegacyHideNotes               = @"LegacyHideNotes";
NSString *const kMPSettingsKeyLegacyHideURL                 = @"LegacyHideURL";

NSString *const kMPSettingsKeyLastDatabasePath              = @"LastDatabasePath";
NSString *const kMPSettingsKeyRememeberdKeysForDatabases    = @"RememeberdKeysForDatabases";
NSString *const kMPSettingsKeyRememberKeyFilesForDatabases  = @"RememberKeyFilesForDatabases";

NSString *const kMPSettingsKeySendCommandForControlKey      = @"SendCommandKeyForControlKey";
NSString *const kMPSettingsKeyEnableGlobalAutotype          = @"EnableGlobalAutotype";

NSString *const kMPSettingsKeyEntrySearchFilterMode         = @"EntrySearchFilterMode";

NSString *const kMPSettingsKeyEnableQuicklookPreview        = @"EnableQuicklookPreview";

NSString *const kMPSettingsKeyCopyGeneratedPasswordToClipboard = @"CopyGeneratedPasswordToClipboard";

@implementation MPSettingsHelper

+ (void)setupDefaults {
  [[NSUserDefaults standardUserDefaults] registerDefaults:[self _standardDefaults]];
}

+ (void)migrateDefaults {
  [self _fixEntryTableSortDescriptors];
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
           kMPSettingsKeyRememberKeyFilesForDatabases: @NO,
           kMPSettingsKeySendCommandForControlKey: @YES,
           kMPSettingsKeyEntrySearchFilterMode: @0,
           kMPSettingsKeyEnableGlobalAutotype: @NO,
           kMPSettingsKeyEnableQuicklookPreview: @NO,
           kMPSettingsKeyCopyGeneratedPasswordToClipboard: @NO,
           };
}

+ (void)_fixEntryTableSortDescriptors {
  /*
   MacPass < 0.4 did use compare: for the entry table view,
   this was changed in 0.4 to localizedCaseInsensitiveCompare:
   */
  NSData *descriptorData = [[NSUserDefaults standardUserDefaults] dataForKey:kMPSettingsKeyEntryTableSortDescriptors];
  if(!descriptorData) {
    return; // No user defaults
  }
  NSArray *sortDescriptors = [NSUnarchiver unarchiveObjectWithData:descriptorData];
  for(NSSortDescriptor *descriptor in sortDescriptors) {
    if([descriptor selector] == @selector(compare:)) {
      [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMPSettingsKeyEntryTableSortDescriptors];
      break;
    }
  }
}

@end
