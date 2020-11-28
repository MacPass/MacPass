//
//  KPKEntry+OTP.m
//  MacPass
//
//  Created by Michael Starke on 25.11.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "KPKEntry+OTP.h"

@implementation KPKEntry (OTP)

NSString *const MPHMACOTPSeedAttributeKey = @"HMACOTP-Seed";
NSString *const MPHMACOTPConfigAttributeKey = @"HMACOTP-Config";
NSString *const MPTOTPAuthAttributeKey = @"otp";
NSString *const MPTOTPSeedAttributeKey = @"TOTP Seed";
NSString *const MPTOTPConfigAttributeKey = @"OTP Settings";

+ (NSSet<NSString *> *)keyPathsForValuesAffectingHasTOTP {
  return [NSSet setWithObject:NSStringFromSelector(@selector(attributes))];
}

- (BOOL)hasTOTP {
  BOOL hasURLKey = [self hasAttributeWithKey:MPTOTPAuthAttributeKey];
  BOOL hasSeedKey = [self hasAttributeWithKey:MPTOTPSeedAttributeKey];
  BOOL hasSettingsKey = [self hasAttributeWithKey:MPTOTPConfigAttributeKey];
  
  return(hasURLKey || (hasSeedKey && hasSettingsKey));
}

@end
