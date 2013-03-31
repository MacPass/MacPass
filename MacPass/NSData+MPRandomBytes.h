//
//  NSData+MPRandomBytes.h
//  MacPass
//
//  Created by Michael Starke on 30.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (MPRandomBytes)

+ (NSData *)dataWithRandomBytes:(NSUInteger)lenght;

@end
