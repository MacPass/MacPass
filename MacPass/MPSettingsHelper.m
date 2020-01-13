//
//  MPSettingsHelper.m
//  MacPass
//
//  Created by Michael Starke on 30.03.13.
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

#import "MPSettingsHelper.h"
#import "NSString+MPPasswordCreation.h"
#import "NSString+MPHash.h"
#import "MPEntrySearchContext.h"
#import "DDHotKey+MacPassAdditions.h" // Default hotkey;

NSString *const kMPSettingsKeyPasteboardClearTimeout                  = @"ClipboardClearTimeout";
NSString *const kMPSettingsKeyClearPasteboardOnQuit                   = @"ClearClipboardOnQuit";
NSString *const kMPSettingsKeyPreventUniversalClipboard               = @"PreventUniversalClipboard";
NSString *const kMPSettingsKeyBrowserBundleId                         = @"BrowserBundleId";
NSString *const kMPSettingsKeyOpenEmptyDatabaseOnLaunch               = @"OpenEmptyDatabaseOnLaunch";
NSString *const kMPSettingsKeyReopenLastDatabaseOnLaunch              = @"ReopenLastDatabaseOnLaunch";
NSString *const kMPSettingsKeyQuitOnLastWindowClose                   = @"QuitOnLastWindowClose";
NSString *const kMPSettingsKeyFileChangeStrategy                      = @"FileChangeStrategy";
NSString *const kMPSettingsKeyEnableAutosave                          = @"EnableAutosave";
NSString *const kMPSettingsKeyLockOnSleep                             = @"LockOnSleep";
NSString *const kMPSettingskeyLockOnLogout                            = @"LockOnLogout";
NSString *const kMPSettingskeyLockOnScreenSleep                       = @"LockOnScreenSleep";
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
NSString *const kMPSettingsKeyAutotypeMatchTitle                      = @"AutotypeMatchTitle";
NSString *const kMPSettingsKeyAutotypeMatchURL                        = @"AutotypeMatchURL";
NSString *const kMPSettingsKeyAutotypeMatchHost                       = @"AutotypeMatchHost";
NSString *const kMPSettingsKeyAutotypeMatchTags                       = @"AutotypeMatchTags";
NSString *const kMPSettingsKeyAutotpyeHideMissingPermissionsWarning   = @"AutotpyeHideMissingPermissionsWarning";

NSString *const kMPSettingsKeyEntrySearchFilterContext                = @"EntrySearchFilterContext";

NSString *const kMPSettingsKeyEnableQuicklookPreview                  = @"EnableQuicklookPreview";

NSString *const kMPSettingsKeyCopyGeneratedPasswordToClipboard        = @"CopyGeneratedPasswordToClipboard";

NSString *const kMPSettingsKeyDefaultPasswordLength                   = @"DefaultPasswordLength";
NSString *const kMPSettingsKeyPasswordCharacterFlags                  = @"PasswordCharacterFlags";
NSString *const kMPSettingsKeyPasswordEnsureOccurance                 = @"PasswordEnsureOccurance";
NSString *const kMPSettingsKeyPasswordUseCustomString                 = @"PasswordUseCustomString";
NSString *const kMPSettingsKeyPasswordCustomString                    = @"PasswordCustomString";

NSString *const kMPSettingsKeyPasswordDefaultsForEntry                = @"PasswordDefaultsForEntry";

NSString *const kMPSettingsKeyDoubleClickURLAction                    = @"DoubleClickURLAction";
NSString *const kMPSettingsKeyDoubleClickTitleAction                  = @"DoubleClickTitleAction";
NSString *const kMPSettingsKeyUpdatePasswordOnTemplateEntries         = @"UpdatePasswordOnTemplateEntries";
NSString *const kMPSettingsKeyHideAfterCopyToClipboard                = @"HideAfterCopyToClipboard";

NSString *const kMPSettingsKeyLoadUnsecurePlugins                     = @"LoadUnsecurePlugins";
NSString *const kMPSettingsKeyLoadIncompatiblePlugins                 = @"LoadIncompatiblePlugins";
NSString *const kMPSettingsKeyDisabledPlugins                         = @"DisabledPlugins";
NSString *const kMPSettingsKeyHideIncopatiblePluginsWarning           = @"HideIncopatiblePluginsWarning";
NSString *const kMPSettingsKeyAllowRemoteFetchOfPluginRepository      = @"AllowRemoteFetchOfPluginRepository";

/* Deprecated */
NSString *const kMPDeprecatedSettingsKeyRememberKeyFilesForDatabases      = @"kMPSettingsKeyRememberKeyFilesForDatabases";
NSString *const kMPDeprecatedSettingsKeyLastDatabasePath                  = @"MPLastDatabasePath";
NSString *const kMPDeprecatedSettingsKeyDocumentsAutotypeFixNoteWasShown  = @"DocumentsAutotypeFixNoteWasShown";
NSString *const kMPDeprecatedSettingsKeyDoubleClickURLToLaunch            = @"DoubleClickURLToLaunch";
NSString *const kMPDeprecatedSettingsKeyEntrySearchFilterMode             = @"EntrySearchFilterMode";
NSString *const kMPDeprecatedSettingsKeyHttpPort                          = @"HttpPort";
NSString *const kMPDeprecatedSettingsKeyEnableHttpServer                  = @"EnableHttpServer";
NSString *const kMPDeprecatedSettingsKeyShowMenuItem                      = @"ShowMenuItem";
NSString *const kMPDeprecatedSettingsKeyDefaultPasswordRounds             = @"KeyDefaultPasswordRounds";
NSString *const kMPDepricatedSettingsKeyLoadUnsecurePlugins               = @"MPLoadUnsecurePlugins";
NSString *const kMPDepricatedSettingsKeyAutotypeHideAccessibiltyWarning   = @"AutotypeHideAccessibiltyWarning";

@implementation MPSettingsHelper

+ (void)setupDefaults {
  [NSUserDefaults.standardUserDefaults registerDefaults:[self _standardDefaults]];
}

+ (void)migrateDefaults {
  [self _fixEntryTableSortDescriptors];
  [self _migrateURLDoubleClickPreferences];
  [self _migrateEntrySearchFlags];
  [self _migrateRememberedKeyFiles];
  [self _migrateLoadUnsecurePlugins];
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
                         kMPSettingsKeyClearPasteboardOnQuit: @YES, // Clear Clipboard on quit
                         kMPSettingsKeyPreventUniversalClipboard: @YES, // Disable Universal Clipboard by default
                         kMPSettingsKeyOpenEmptyDatabaseOnLaunch: @NO,
                         kMPSettingsKeyReopenLastDatabaseOnLaunch: @YES,
                         kMPSettingsKeyFileChangeStrategy: @(MPFileChangeStrategyAsk), // Ask what to do on a file change!
                         kMPSettingsKeyLockOnSleep: @YES,
                         kMPSettingskeyLockOnLogout: @NO,
                         kMPSettingskeyLockOnScreenSleep: @NO,
                         kMPSettingsKeyIdleLockTimeOut: @0, // Do not lock while idle by default
                         kMPSettingsKeyLegacyHideNotes: @NO,
                         kMPSettingsKeyLegacyHidePassword: @YES,
                         kMPSettingsKeyLegacyHideTitle: @NO,
                         kMPSettingsKeyLegacyHideURL: @NO,
                         kMPSettingsKeyLegacyHideUsername: @NO,
                         kMPSettingsKeyRememberKeyFilesForDatabases: @NO,
                         kMPSettingsKeySendCommandForControlKey: @YES, // translate Ctrl to Cmd by default
                         kMPSettingsKeyEnableGlobalAutotype: @NO, // Keep global autotype disabled by default
                         kMPSettingsKeyGlobalAutotypeKeyDataKey: DDHotKey.defaultHotKeyData, // Cmd + Alt + M
                         kMPSettingsKeyDefaultGlobalAutotypeSequence: @"{USERNAME}{TAB}{PASSWORD}{ENTER}",
                         kMPSettingsKeyAutotypeMatchTitle: @YES,
                         kMPSettingsKeyAutotypeMatchURL: @NO,
                         kMPSettingsKeyAutotypeMatchHost: @NO,
                         kMPSettingsKeyAutotypeMatchTags: @NO,
                         kMPSettingsKeyEnableQuicklookPreview: @NO,
                         kMPSettingsKeyCopyGeneratedPasswordToClipboard: @NO,
                         kMPSettingsKeyDefaultPasswordLength: @12,
                         kMPSettingsKeyPasswordCharacterFlags: @(MPPasswordCharactersAll),
                         kMPSettingsKeyPasswordUseCustomString: @NO,
                         kMPSettingsKeyPasswordCustomString: @"",
                         kMPSettingsKeyPasswordEnsureOccurance: @NO,
                         kMPSettingsKeyDoubleClickURLAction: @(MPDoubleClickURLActionCopy),
                         kMPSettingsKeyDoubleClickTitleAction: @(MPDoubleClickTitleActionInspect),
                         kMPSettingsKeyLoadUnsecurePlugins: @NO,
                         kMPSettingsKeyUpdatePasswordOnTemplateEntries: @YES,
                         kMPSettingsKeyDisabledPlugins: @[],
                         kMPSettingsKeyLoadIncompatiblePlugins: @NO,
                         kMPSettingsKeyQuitOnLastWindowClose: @NO,
                         kMPSettingsKeyEnableAutosave: @YES,
                         kMPSettingsKeyHideAfterCopyToClipboard: @NO
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
                            kMPDeprecatedSettingsKeyEntrySearchFilterMode,
                            kMPDeprecatedSettingsKeyDefaultPasswordRounds,
                            /* Moved to KeePassHttp Plugin */
                            kMPDeprecatedSettingsKeyHttpPort,
                            kMPDeprecatedSettingsKeyEnableHttpServer,
                            kMPDeprecatedSettingsKeyShowMenuItem,
                            kMPDepricatedSettingsKeyLoadUnsecurePlugins,
                            kMPDepricatedSettingsKeyAutotypeHideAccessibiltyWarning
                            ];
  });
  return deprecatedSettings;
}


+ (void)_removeDeprecatedValues {
  /* Clear old style values */
  for(NSString *key in [self _deprecatedSettingsKeys]) {
    [NSUserDefaults.standardUserDefaults removeObjectForKey:key];
  }
}

+ (void)_fixEntryTableSortDescriptors {
  /*
   MacPass < 0.4 did use compare: for the entry table view,
   this was changed in 0.4 to localizedCaseInsensitiveCompare:
   
   MacPass < 0.5.2 did use parent.name for group names,
   this was changed in 0.6. to parent.title
   
   */
  NSData *descriptorData = [NSUserDefaults.standardUserDefaults dataForKey:kMPSettingsKeyEntryTableSortDescriptors];
  if(!descriptorData) {
    return; // No user defaults
  }
  NSArray *sortDescriptors = [NSUnarchiver unarchiveObjectWithData:descriptorData];
  
  for(NSSortDescriptor *descriptor in sortDescriptors) {
    /* Brute force, just kill the settings if they might cause trouble */
    if(descriptor.selector == @selector(compare:)
       || [descriptor.key isEqualToString:@"timeInfo.modificationDate"]
       || [descriptor.key isEqualToString:@"parent.name"] ) {
      [NSUserDefaults.standardUserDefaults removeObjectForKey:kMPSettingsKeyEntryTableSortDescriptors];
      break;
    }
  }
}

+ (void)_migrateURLDoubleClickPreferences {
  /*
   Default was NO so if the key was not set the correct action now should be MPDoubleClickURLActionCopy
   But MPDoubleClickURLActionCopy is the default we cannot simply add this value.
   Hence we chose to only migrate a changed default and let the "old" default silenty be updated
   This is a worth trade-off since the other solution will always re-set the default
   */
  if(nil == [NSUserDefaults.standardUserDefaults objectForKey:kMPDeprecatedSettingsKeyDoubleClickURLToLaunch]) {
    return; // the value was not set, do nothing since we cannot determine what to do
  }
  /* only update the settings if the defaults return an explicit set value */
  if([NSUserDefaults.standardUserDefaults boolForKey:kMPDeprecatedSettingsKeyDoubleClickURLToLaunch]) {
    [NSUserDefaults.standardUserDefaults setInteger:MPDoubleClickURLActionOpen forKey:kMPSettingsKeyDoubleClickURLAction];
  }
}

+ (void)_migrateEntrySearchFlags {
  /* Entry filters are now stored as archived search context not just flags */
  NSInteger flags = [NSUserDefaults.standardUserDefaults integerForKey:kMPDeprecatedSettingsKeyEntrySearchFilterMode];
  if(flags != 0) {
    MPEntrySearchContext *context = [[MPEntrySearchContext alloc] initWithString:nil flags:flags];
    NSData *contextData = [NSKeyedArchiver archivedDataWithRootObject:context];
    [NSUserDefaults.standardUserDefaults setObject:contextData forKey:kMPSettingsKeyEntrySearchFilterContext];
  }
}

+ (void)_migrateRememberedKeyFiles {
  /*
   Database file paths was stored as plain text in keyfile mapping.
   We only need to store the key file url in plain text, thus hashing the path is sufficent
   */
  NSDictionary<NSString *, NSString *> *currentMapping = [NSUserDefaults.standardUserDefaults dictionaryForKey:kMPSettingsKeyRememeberdKeysForDatabases];
  if(!currentMapping) {
    return;
  }
  NSMutableDictionary *hashedDict = [[NSMutableDictionary alloc] initWithCapacity:MAX(1,currentMapping.count)];
  BOOL didHash = NO;
  for(NSString *key in currentMapping) {
    NSURL *fileURL = [NSURL URLWithString:key];
    /* Only hash file paths */
    if(fileURL.isFileURL) {
      NSString *digest = key.sha1HexDigest;
      if(digest) {
        hashedDict[key.sha1HexDigest] = currentMapping[key];
        didHash = YES;
      }
    }
    /* keep all hashed or unknown data */
    else {
      hashedDict[key] = currentMapping[key];
    }
  }
  if(didHash) {
    [NSUserDefaults.standardUserDefaults setObject:hashedDict forKey:kMPSettingsKeyRememeberdKeysForDatabases];
  }
}

+ (void)_migrateLoadUnsecurePlugins {
  id value = [NSUserDefaults.standardUserDefaults objectForKey:kMPDepricatedSettingsKeyLoadUnsecurePlugins];
  if(!value) {
    return; // value already migrated or was set to default value
  }
  BOOL oldValue = [NSUserDefaults.standardUserDefaults boolForKey:kMPDepricatedSettingsKeyLoadUnsecurePlugins];
  if(oldValue != [[self _standardDefaults][kMPDepricatedSettingsKeyLoadUnsecurePlugins] boolValue]) {
    [NSUserDefaults.standardUserDefaults setBool:oldValue forKey:kMPSettingsKeyLoadUnsecurePlugins];
  }
  
}

@end
