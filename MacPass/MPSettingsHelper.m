//
//  MPSettingsHelper.m
//  MacPass
//
//  Created by Michael Starke on 30.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPSettingsHelper.h"

NSString *const kMPSettingsKeyPasteboardClearTimeout = @"ClipboardClearTimeout";
NSString *const kMPSettingsKeyClearPasteboardOnQuit  = @"ClearClipboardOnQuit";
NSString *const kMPSettingsKeyOpenEmptyDatabaseOnLaunch = @"OpenEmptyDatabaseOnLaunch";

@implementation MPSettingsHelper

+ (void)setupDefaults {
  [[NSUserDefaults standardUserDefaults] registerDefaults:[self _standardDefaults]];
}

+ (NSDictionary *)_standardDefaults {
  return @{
           kMPSettingsKeyPasteboardClearTimeout: @10,
           kMPSettingsKeyClearPasteboardOnQuit: @YES,
           kMPSettingsKeyOpenEmptyDatabaseOnLaunch: @YES,
           };
}

@end