//
//  NSData+MPRandomBytes.m
//  MacPass
//
//  Created by Michael Starke on 30.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "NSData+MPRandomBytes.h"
#import <Security/SecRandom.h>

@implementation NSData (MPRandomBytes)

+ (NSData *)dataWithRandomBytes:(NSUInteger)length {
  NSLog(@"requesting %ld bytes", length);
  unsigned char *bytes = malloc(sizeof(unsigned char) * length);
  SecRandomCopyBytes(kSecRandomDefault, length, bytes);
  return [NSData dataWithBytesNoCopy:bytes length:length freeWhenDone:YES];
}

@end
