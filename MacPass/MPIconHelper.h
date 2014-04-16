//
//  MPIconHelper.h
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *	Available IconTypes
 *  Every Icon after MPCustomIconTypeBegin
 *  is not suitable for usage as KDB Icon
 */
typedef NS_ENUM(NSUInteger, MPIconType) {
  MPIconPassword,
  MPIconPackageNetwork,
  MPIconWarning,
  MPIconServer,
  MPIconKlipper,
  MPIconLanguages,
  MPIconBlockDevice,
  MPIconNotepad,
  MPIconSocket,
  MPIconIdentity,
  MPIconContact,
  MPIconCamera,
  MPIconRemote,
  MPIconKeys,
  MPIconBattery,
  MPIconScanner,
  MPIconBrowser,
  MPIconCDRom,
  MPIconDisplay,
  MPIconEmail,
  MPIconMisc,
  MPIconFileSave = 26,
  MPIconTerminal = 30,
  MPIconPrint = 31,
  MPIconTrash = 43,
  MPIconFolder = 48,
  MPIconPhone = 68,
  /* Custom Icons not used in Database */
  MPCustomIconTypeBegin = 1000,
  MPIconInfo,
  MPIconAddFolder,
  MPIconHardDisk,
  MPIconCreated,
  MPIconAddEntry,
  MPIconContextTriangle,
  MPIconExpiredEntry,
  MPIconExpiredGroup,
};

/**
 *	Helper class to retrieve Icons for Keys. KDB sortes Icons as an Integer
 *  The Helper maps those numbers to icons.
 *  It can furthermore be used to retrieve other Icons, that are non-Database Icons
 */
@interface MPIconHelper : NSObject

/**
 *	Returns the Icon Image for a given type
 *	@param	type	Icontype
 *	@return	Image for the IconType
 */
+ (NSImage *)icon:(MPIconType)type;

/**
 *	Available Icon names (all)
 *	@return	Dictioary with MPIconType keys and NSString values containing their names
 */
+ (NSDictionary *)availableIconNames;

/**
 *	List of all available DatabaseIcons as an array of Images. Sorted by IconIndex.
 *	@return	Array of Icons as NSImage objects
 */
+ (NSArray *)databaseIcons;

/**
 *	List of all available DatabaseIcons as an array of MPIconType. Sorted by IconIndex.
 *	@return	Array of MPIconType as NSNumber objects
 */
+ (NSArray *)databaseIconTypes;

@end
