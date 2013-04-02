//
//  MPSettingsHelper.h
//  MacPass
//
//  Created by Michael Starke on 30.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

APPKIT_EXTERN NSString *const kMPSettingsKeyPasteboardClearTimeout;
APPKIT_EXTERN NSString *const kMPSettingsKeyClearPasteboardOnQuit;
APPKIT_EXTERN NSString *const kMPSettingsKeyPasswordEncoding;

typedef enum {
  MPPasswordEncodingUTF8,
  MPPasswordEncodingASCII,
} MPPasswordEncoding;

@interface MPSettingsHelper : NSObject

+ (void)setupDefaults;

@end