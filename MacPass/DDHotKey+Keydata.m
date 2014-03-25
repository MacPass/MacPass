//
//  DDHotKey+Coding.m
//  MacPass
//
//  Created by Michael Starke on 25/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "DDHotKey+Keydata.h"

@implementation DDHotKey (Keydata)

- (instancetype)initWithKeyData:(NSData *)data {
  NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
  unsigned short keyCode = [unarchiver decodeIntForKey:NSStringFromSelector(@selector(keyCode))];
  NSUInteger modiferFlags = [unarchiver decodeIntegerForKey:NSStringFromSelector(@selector(modifierFlags))];
  self = [DDHotKey hotKeyWithKeyCode:keyCode modifierFlags:modiferFlags task:nil];
  return self;
}

- (NSData *)keyData {
  NSMutableData *data = [[NSMutableData alloc] init];
  NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  [archiver encodeInt:self.keyCode forKey:NSStringFromSelector(@selector(keyCode))];
  [archiver encodeInteger:self.modifierFlags forKey:NSStringFromSelector(@selector(modifierFlags))];
  [archiver finishEncoding];
  return  [data copy];
}

@end
