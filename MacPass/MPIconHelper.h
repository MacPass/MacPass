//
//  MPIconHelper.h
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MPIconType) {
  MPIconPassword,
  MPIconPackageNetwork,
  MPIconWarning,
  MPIconServer,
  MPIconKlipper,
  MPIconLanguages,
  MPIconNotepad,
  MPIconSocket,
  MPIconIdentity,
  MPIconContact,
  MPIconCamera,
  MPIconTrash,
  MPIconInfo
};

@interface MPIconHelper : NSObject

/*
 @param type  Icon identifier typ MPIconTyp
 @returns Icon for given identifier
 */
+ (NSImage *)icon:(MPIconType)type;
/*
 Available Icons, Use the MPDatabaseIconType to access a individual icon;
 @returns all availble Icons
 */
+ (NSDictionary *)availableIconNames;

+ (NSArray *)availableIcons;

/*
 @returns a random Icon image
 */
+ (NSImage *)randomIcon;

@end
