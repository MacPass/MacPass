//
//  MPSettingsHelper.h
//  MacPass
//
//  Created by Michael Starke on 30.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/* Clipboard */
APPKIT_EXTERN NSString *const kMPSettingsKeyPasteboardClearTimeout;
APPKIT_EXTERN NSString *const kMPSettingsKeyClearPasteboardOnQuit;

/* Behaviour */
APPKIT_EXTERN NSString *const kMPSettingsKeyPasswordEncoding;
APPKIT_EXTERN NSString *const kMPSettingsKeyOpenEmptyDatabaseOnLaunch;
APPKIT_EXTERN NSString *const kMPSettingsKeyReopenLastDatabaseOnLaunch;

/* URL handling */
APPKIT_EXTERN NSString *const kMPSettingsKeyDoubleClickURLToLaunch;
APPKIT_EXTERN NSString *const kMPSettingsKeyBrowserBundleId;

/* Server Settings */
APPKIT_EXTERN NSString *const kMPSettingsKeyHttpPort;
APPKIT_EXTERN NSString *const kMPSettingsKeyEnableHttpServer;
APPKIT_EXTERN NSString *const kMPSettingsKeyShowMenuItem;

/* Autolock */
APPKIT_EXTERN NSString *const kMPSettingsKeyLockOnSleep;
APPKIT_EXTERN NSString *const kMPSettingsKeyIdleLockTimeOut;

/* Autosaving states */
APPKIT_EXTERN NSString *const kMPSettingsKeyShowInspector;
APPKIT_EXTERN NSString *const kMPSettingsKeyEntryTableSortDescriptors;

/* Kdb Hide/Show settings */
APPKIT_EXTERN NSString *const kMPSettingsKeyLegacyHideTitle;
APPKIT_EXTERN NSString *const kMPSettingsKeyLegacyHideUsername;
APPKIT_EXTERN NSString *const kMPSettingsKeyLegacyHidePassword;
APPKIT_EXTERN NSString *const kMPSettingsKeyLegacyHideNotes;
APPKIT_EXTERN NSString *const kMPSettingsKeyLegacyHideURL;

/* Document/Key Location store */
APPKIT_EXTERN NSString *const kMPSettingsKeyLastDatabasePath;
APPKIT_EXTERN NSString *const kMPSettingsKeyRememeberdKeysForDatabases;
APPKIT_EXTERN NSString *const kMPSettingsKeyRememberKeyFilesForDatabases;

/* Autotype */
APPKIT_EXTERN NSString *const kMPSettingsKeySendCommandForControlKey; // Should MacPass swap control for command. This is usefull in a cross plattform environment
APPKIT_EXTERN NSString *const kMPSettingsKeyEnableGlobalAutotype; // Is Global Autotype enabled?
APPKIT_EXTERN NSString *const kMPSettingsKeyGlobalAutotypeKeyDataKey; // The stored Data for the useder defined global autotype key
APPKIT_EXTERN NSString *const kMPSettingsKeyDocumentsAutotypeFixNoteWasShown; //

/* Search */
APPKIT_EXTERN NSString *const kMPSettingsKeyEntrySearchFilterMode;

/* Quicklook */
APPKIT_EXTERN NSString *const kMPSettingsKeyEnableQuicklookPreview;

/* Password Generation */
APPKIT_EXTERN NSString *const kMPSettingsKeyCopyGeneratedPasswordToClipboard;
APPKIT_EXTERN NSString *const kMPSettingsKeyDefaultPasswordRounds;
APPKIT_EXTERN NSString *const kMPSettingsKeyDefaultPasswordLength;
APPKIT_EXTERN NSString *const kMPSettingsKeyPasswordCharacterFlags;
APPKIT_EXTERN NSString *const kMPSettingsKeyPasswordUseCustomString;
APPKIT_EXTERN NSString *const kMPSettingsKeyPasswordCustomString;

typedef NS_ENUM(NSUInteger, MPPasswordEncoding) {
  MPPasswordEncodingUTF8,
  MPPasswordEncodingASCII,
};

@interface MPSettingsHelper : NSObject

/**
 *  Registers all the defaults for the applciaiton
 */
+ (void)setupDefaults;

/**
 *  Brings the defaults to a current status. Removes obsoltes entries.
 */
+ (void)migrateDefaults;
/**
 *  Convenience Method to create a bind path for the NSUserDefaultsController
 *
 *  @param key SettingsKey (see MPSettingsHelper.h for available keys)
 *
 *  @return NSString containing the bindpath for this property for the NSUserDefaultController
 */
+ (NSString *)defaultControllerPathForKey:(NSString *)key;

@end