//
//  MPIconHelper.h
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  MPIconPassword,
  MPIconPackageNetwork,
  MPIconWarning,
  MPIconServer,
  MPIconKlipper,
  MPIconLanguages
} MPIconType;

@interface MPIconHelper : NSObject

+ (NSImage *)icon:(MPIconType)type;
/*
 Available Icons, Use the MPDatabaseIconType to access a individual icon;
 */
+ (NSDictionary *)availableIcons;

@end
