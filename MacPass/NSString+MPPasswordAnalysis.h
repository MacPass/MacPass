//
//  NSString+MPPasswordAnalysis.h
//  MacPass
//
//  Created by Michael Starke on 29.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MPPasswordStrength) {
  MPPasswordWeak,
  MPPasswordOK,
  MPPasswordGood,
  MPPasswordStrong,
  MPPasswordExcelent,
};

@interface NSString (MPPasswordAnalysis)

- (MPPasswordStrength)passwordStrenght;

@end
