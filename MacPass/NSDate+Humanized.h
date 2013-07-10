//
//  NSDate+Humanized.h
//  MacPass
//
//  Created by Michael Starke on 10.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Humanized)

+ (NSString *)humanizedDate:(NSDate *)date;
- (NSString *)humanized;

@end
