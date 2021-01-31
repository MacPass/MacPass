//
//  NSRunningApplication+MPAdditions.h
//  MacPass
//
//  Created by Michael Starke on 15.01.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

APPKIT_EXTERN NSString *const MPWindowIDKey;
APPKIT_EXTERN NSString *const MPWindowTitleKey;
APPKIT_EXTERN NSString *const MPProcessIdentifierKey;


@interface NSRunningApplication (MPAdditions)

@property (readonly, copy) NSDictionary *mp_infoDictionary;

@end

NS_ASSUME_NONNULL_END
