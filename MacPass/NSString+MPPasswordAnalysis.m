//
//  NSString+MPPasswordAnalysis.m
//  MacPass
//
//  Created by Michael Starke on 29.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "NSString+MPPasswordAnalysis.h"

@implementation NSString (MPPasswordAnalysis)

- (MPPasswordStrength)passwordStrenght {
  return MPPasswordOK;
}

@end
