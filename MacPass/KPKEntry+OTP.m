//
//  KPKEntry+OTP.m
//  MacPass
//
//  Created by Michael Starke on 25.11.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "KPKEntry+OTP.h"

@implementation KPKEntry (OTP)

+ (NSSet<NSString *> *)keyPathsForValuesAffectingHasTOTP {
  return [NSSet setWithObject:NSStringFromSelector(@selector(attributes))];
}

- (BOOL)hasTOTP {
  BOOL hasURLKey = [self hasAttributeWithKey:kKPKAttributeKeyOTPOAuthURL];
  BOOL hasSeedKey = [self hasAttributeWithKey:kKPKAttributeKeyTimeOTPSeed];
  BOOL hasSettingsKey = [self hasAttributeWithKey:kKPKAttributeKeyTimeOTPSettings];
  
  return(hasURLKey || (hasSeedKey && hasSettingsKey));
}

@end
