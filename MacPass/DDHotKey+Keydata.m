//
//  DDHotKey+Coding.m
//  MacPass
//
//  Created by Michael Starke on 25/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "DDHotKey+Keydata.h"
#import <Carbon/Carbon.h>

@implementation DDHotKey (Keydata)

+ (instancetype)defaultHotKey {
  return [DDHotKey defaultHotKeyWithTask:nil];
}

+ (instancetype)defaultHotKeyWithTask:(DDHotKeyTask)task {
  return [[DDHotKey alloc] initWithKeyData:nil];
}

- (instancetype)initWithKeyData:(NSData *)data {
  self = [self initWithKeyData:data taks:nil];
  return self;
}

- (instancetype)initWithKeyData:(NSData *)data taks:(DDHotKeyTask)task{
  NSUInteger modifierFlags;
  unsigned short keyCode;
  if(!data) {
    self = [DDHotKey hotKeyWithKeyCode:kVK_ANSI_M modifierFlags:kCGEventFlagMaskControl|kCGEventFlagMaskAlternate task:task];
  }
  else if([self _getKeyCode:&keyCode modifierFlags:&modifierFlags fromData:data]) {
    self = [DDHotKey hotKeyWithKeyCode:keyCode modifierFlags:modifierFlags task:task];
  }
  else {
    self = nil;
  }
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


- (BOOL)_getKeyCode:(unsigned short *)keyCode modifierFlags:(NSUInteger *)modifierFlags fromData:(NSData *)data {
  if(keyCode == NULL || modifierFlags == NULL || data == nil) {
    return NO;
  }
  NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
  *keyCode = [unarchiver decodeIntForKey:NSStringFromSelector(@selector(keyCode))];
  *modifierFlags = [unarchiver decodeIntegerForKey:NSStringFromSelector(@selector(modifierFlags))];
  return YES;
}
@end
