//
//  NSString+MPPasswordAnalysis.h
//  MacPass
//
//  Created by Michael Starke on 29.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  MPPasswordWeak,
  MPPasswordOK,
  MPPasswordGood,
  MPPasswordStrong,
  MPPasswordExcelent,
} MPPasswordStrength;

@interface NSString (MPPasswordAnalysis)

- (MPPasswordStrength)passwordStrenght;

@end
