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
APPKIT_EXTERN NSString *const kMPSettingsKeyDoubleClickURLToLaunch;

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
/*
APPKIT_EXTERN NSString *const kMPSettingsKeyLastKeyURL;
APPKIT_EXTERN NSString *const kMPSettingsKeyRememberLastKey;
*/

typedef NS_ENUM(NSUInteger, MPPasswordEncoding) {
  MPPasswordEncodingUTF8,
  MPPasswordEncodingASCII,
};

@interface MPSettingsHelper : NSObject

+ (void)setupDefaults;
+ (NSString *)defaultControllerPathForKey:(NSString *)key;

@end