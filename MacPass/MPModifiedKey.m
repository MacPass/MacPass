//
//  MPModifiedKey.m
//  MacPass
//
//  Created by Michael Starke on 26/01/2017.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPModifiedKey.h"

@implementation NSValue(NSValueMPModifiedKeyExtensions)

- (MPModifiedKey)modifiedKeyValue {
  MPModifiedKey key;
  [self getValue:&key];
  return key;
}

+ (instancetype)valueWithModifiedKey:(MPModifiedKey)key {
  return [NSValue valueWithBytes:&key objCType:@encode(MPModifiedKey)];
}

@end

