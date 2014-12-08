//
//  MPSettingsHelper.m
//  MacPass
//
//  Created by Michael Starke on 30.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPSettingsHelper.h"
#import "NSString+MPPasswordCreation.h"
#import "MPEntryViewController.h" // Sort descriptors
#import "DDHotKey+MacPassAdditions.h" // Default hotkey;

NSString *const kMPSettingsKeyPasteboardClearTimeout                  = @"ClipboardClearTimeout";
NSString *const kMPSettingsKeyClearPasteboardOnQuit                   = @"ClearClipboardOnQuit";
NSString *const kMPSettingsKeyBrowserBundleId                         = @"BrowserBundleId";
NSString *const kMPSettingsKeyOpenEmptyDatabaseOnLaunch               = @"OpenEmptyDatabaseOnLaunch";
NSString *const kMPSettingsKeyReopenLastDatabaseOnLaunch              = @"ReopenLastDatabaseOnLaunch";
NSString *const kMPSettingsKeyHttpPort                                = @"HttpPort";
NSString *const kMPSettingsKeyEnableHttpServer                        = @"EnableHttpServer";
NSString *const kMPSettingsKeyShowMenuItem                            = @"ShowMenuItem";
NSString *const kMPSettingsKeyLockOnSleep                             = @"LockOnSleep";
NSString *const kMPSettingsKeyIdleLockTimeOut                         = @"IdleLockTimeOut";
NSString *const kMPSettingsKeyShowInspector                           = @"ShowInspector";
NSString *const kMPSettingsKeyEntryTableSortDescriptors               = @"EntryTableSortDescriptors";

NSString *const kMPSettingsKeyLegacyHideTitle                         = @"LegacyHideTitle";
NSString *const kMPSettingsKeyLegacyHideUsername                      = @"LegacyHideUsername ";
NSString *const kMPSettingsKeyLegacyHidePassword                      = @"LegacyHidePassword";
NSString *const kMPSettingsKeyLegacyHideNotes                         = @"LegacyHideNotes";
NSString *const kMPSettingsKeyLegacyHideURL                           = @"LegacyHideURL";

NSString *const kMPSettingsKeyLastDatabasePath                        = @"LastDatabasePath";
NSString *const kMPSettingsKeyRememberKeyFilesForDatabases            = @"RememberKeyFilesForDatabases";
NSString *const kMPSettingsKeyRememeberdKeysForDatabases              = @"RememeberdKeysForDatabases";

NSString *const kMPSettingsKeySendCommandForControlKey                = @"SendCommandKeyForControlKey";
NSString *const kMPSettingsKeyEnableGlobalAutotype                    = @"EnableGlobalAutotype";
NSString *const kMPSettingsKeyGlobalAutotypeKeyDataKey                = @"GlobalAutotypeKeyDataKey";
NSString *const kMPSettingsKeyDefaultGlobalAutotypeSequence           = @"DefaultGlobalAutotypeSequence";
NSString *const kMPSettingsKeyAutotypeMatchURL                        = @"AutotypeMatchURL";
NSString *const kMPSettingsKeyAutotypeMatchHost                       = @"AutotypeMatchHost";
NSString *const kMPSettingsKeyAutotypeMatchTags                       = @"AutotypeMatchTags";

NSString *const kMPSettingsKeyEntrySearchFilterContext                = @"EntrySearchFilterContext";

NSString *const kMPSettingsKeyEnableQuicklookPreview                  = @"EnableQuicklookPreview";

NSString *const kMPSettingsKeyCopyGeneratedPasswordToClipboard        = @"CopyGeneratedPasswordToClipboard";

NSString *const kMPSettingsKeyDefaultPasswordRounds                   = @"KeyDefaultPasswordRounds";
NSString *const kMPSettingsKeyDefaultPasswordLength                   = @"DefaultPasswordLength";
NSString *const kMPSettingsKeyPasswordCharacterFlags                  = @"PasswordCharacterFlags";
NSString *const kMPSettingsKeyPasswordUseCustomString                 = @"PasswordUseCustomString";
NSString *const kMPSettingsKeyPasswordCustomString                    = @"PasswordCustomString";

NSString *const kMPSettingsKeyPasswordDefaultsForEntry                = @"PasswordDefaultsForEntry";

NSString *const kMPSettingsKeyDoubleClickURLAction                    = @"DoubleClickURLAction";
NSString *const kMPSettingsKeyDoubleClickTitleAction                  = @"DoubleClickTitleAction";

/* Deprecated */
NSString *const kMPDeprecatedSettingsKeyRememberKeyFilesForDatabases      = @"kMPSettingsKeyRememberKeyFilesForDatabases";
NSString *const kMPDeprecatedSettingsKeyLastDatabasePath                  = @"MPLastDatabasePath";
NSString *const kMPDeprecatedSettingsKeyDocumentsAutotypeFixNoteWasShown  = @"DocumentsAutotypeFixNoteWasShown";
NSString *const kMPDeprecatedSettingsKeyDoubleClickURLToLaunch            = @"DoubleClickURLToLaunch";
NSString *const kMPDeprecatedSettingsKeyEntrySearchFilterMode             = @"EntrySearchFilterMode";

@implementation MPSettingsHelper

+ (void)setupDefaults {
  [[NSUserDefaults standardUserDefaults] registerDefaults:[self _standardDefaults]];
}

+ (void)migrateDefaults {
  [self _fixEntryTableSortDescriptors];
  [self _migrateURLDoubleClickPreferences];
  [self _migrateEntrySearchFlags];
  [self _removeDeprecatedValues];
}

+ (NSString *)defaultControllerPathForKey:(NSString *)key {
  return [NSString stringWithFormat:@"values.%@", key];
}

+ (NSDictionary *)_standardDefaults {
  static NSDictionary *standardDefaults;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    standardDefaults = @{
                         kMPSettingsKeyShowInspector: @YES, // Show the Inspector by default
                         kMPSettingsKeyPasteboardClearTimeout: @30, // 30 seconds
                         kMPSettingsKeyClearPasteboardOnQuit: @YES,
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
                         kMPSettingsKeyEnableGlobalAutotype: @NO,
                         kMPSettingsKeyGlobalAutotypeKeyDataKey: [[DDHotKey defaultHotKey] keyData],
                         kMPSettingsKeyDefaultGlobalAutotypeSequence: @"{USERNAME}{TAB}{PASSWORD}{ENTER}",
                         kMPSettingsKeyAutotypeMatchURL: @NO,
                         kMPSettingsKeyAutotypeMatchHost: @NO,
                         kMPSettingsKeyAutotypeMatchTags: @NO,
                         kMPSettingsKeyEnableQuicklookPreview: @NO,
                         kMPSettingsKeyCopyGeneratedPasswordToClipboard: @NO,
                         kMPSettingsKeyDefaultPasswordRounds: @50000,
                         kMPSettingsKeyDefaultPasswordLength: @12,
                         kMPSettingsKeyPasswordCharacterFlags: @(MPPasswordCharactersAll),
                         kMPSettingsKeyPasswordUseCustomString: @NO,
                         kMPSettingsKeyPasswordCustomString: @"",
                         kMPSettingsKeyDoubleClickURLAction: @(MPDoubleClickURLActionCopy),
                         kMPSettingsKeyDoubleClickTitleAction: @(MPDoubleClickTitleActionInspect)
                         };
  });
  return standardDefaults;
}

+ (NSArray *)_deprecatedSettingsKeys {
  static NSArray *deprecatedSettings;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    deprecatedSettings = @[ kMPDeprecatedSettingsKeyRememberKeyFilesForDatabases,
                            kMPDeprecatedSettingsKeyLastDatabasePath,
                            kMPDeprecatedSettingsKeyDocumentsAutotypeFixNoteWasShown,
                            kMPDeprecatedSettingsKeyDoubleClickURLToLaunch,
                            kMPDeprecatedSettingsKeyEntrySearchFilterMode];
  });
  return deprecatedSettings;
}


+ (void)_removeDeprecatedValues {
  /* Clear old style values */
  for(NSString *key in [self _deprecatedSettingsKeys]) {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
  }
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
    if([descriptor selector] == @selector(compare:) || [[descriptor key] isEqualToString:[MPEntryViewController timeInfoModificationTimeKeyPath]] ) {
      [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMPSettingsKeyEntryTableSortDescriptors];
      break;
    }
  }
}

+ (void)_migrateURLDoubleClickPreferences {
  /* Default was NO so if the key was not set, we also get NO, which is what we want */
  BOOL openURL = [[NSUserDefaults standardUserDefaults] boolForKey:kMPDeprecatedSettingsKeyDoubleClickURLToLaunch];
  if(NO == openURL) {
    [[NSUserDefaults standardUserDefaults] setInteger:MPDoubleClickURLActionOpen forKey:kMPSettingsKeyDoubleClickURLAction];
  }
}

+ (void)_migrateEntrySearchFlags {
  NSInteger flags = [[NSUserDefaults standardUserDefaults] integerForKey:kMPDeprecatedSettingsKeyEntrySearchFilterMode];
  if(flags != 0) {
    MPEntrySearchContext *context = [[MPEntrySearchContext alloc] initWithString:nil flags:flags];
    NSData *contextData = [NSKeyedArchiver archivedDataWithRootObject:context];
    [[NSUserDefaults standardUserDefaults] setObject:contextData forKey:kMPSettingsKeyEntrySearchFilterContext];
  }
}

@end
