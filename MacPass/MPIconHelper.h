//
//  MPIconHelper.h
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
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

@class KPKIcon;

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
  MPIconOrganizer,
  MPIconASCII,
  MPIconIcons,
  MPIconEstablishedConnection,
  MPIconMailFolder,
  MPIconFileSave,
  MPIconNFSUnmount,
  MPIconQuickTime,
  MPIconSecureTerminal,
  MPIconTerminal,
  MPIconPrint,
  MPIconFileSystemView,
  MPIconRun,
  MPIconConfigure,
  MPIconBrowserWindow,
  MPIconArchive,
  MPIconPercentage,
  MPIconSambaUnmount,
  MPIconHistory,
  MPIconFindMail,
  MPIconVector,
  MPIconMemory,
  MPIconTrash,
  MPIconNotes,
  MPIconCancel,
  MPIconHelp,
  MPIconPackage,
  MPIconFolder,
  MPIconFolderOpen,
  MPIconFolderTar,
  MPIconDecrypted,
  MPIconEncrypted,
  MPIconApply,
  MPIconSignature,
  MPIconThumbnail,
  MPIconAddressBook,
  MPIconTextView,
  MPIconSecureAccount,
  MPIconDevelopment,
  MPIconHome,
  MPIconServices,
  MPIconTux,
  MPIconFeather,
  MPIconApple,
  MPIconWiki,
  MPIconMoney,
  MPIconCertificat,
  MPIconPhone,
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
  MPIconKeyboard
};

/**
 *	Helper class to retrieve Icons for Keys. KDB sorts Icons as an Integer
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
 *	@return	Dictionary with MPIconType keys and NSString values containing their names
 */
+ (NSDictionary *)availableIconNames;

/**
 *	List of all available DatabaseIcons as an array of Images. Sorted by IconIndex.
 *	@return	Array of Icons as NSImage objects
 */
+ (NSArray<KPKIcon *> *)databaseIcons;

/**
 *	List of all available DatabaseIcons as an array of MPIconType. Sorted by IconIndex.
 *	@return	Array of MPIconType as NSNumber objects
 */
+ (NSArray *)databaseIconTypes;

+ (void)fetchIconDataForURL:(NSURL *)url completionHandler:(void (^)(NSData *iconData))handler;

@end
