//
//  NSString+MPHash.m
//  MacPass
//
//  Created by Michael Starke on 05/02/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import "NSString+MPHash.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (MPHash)

+ (NSString*)sha1HexDigest:(NSString*)input {
  if(input.length == 0) {
    return nil;
  }
  const char* str = input.UTF8String;
  unsigned char result[CC_SHA1_DIGEST_LENGTH];
  CC_SHA1(str, (CC_LONG)strlen(str), result);
  
  NSMutableString *hexDigest = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH*2];
  for(int i = 0; i<CC_SHA1_DIGEST_LENGTH; i++) {
    [hexDigest appendFormat:@"%02x",result[i]];
  }
  return hexDigest;
}

- (NSString *)sha1HexDigest {
  return [NSString sha1HexDigest:self];
}

@end
