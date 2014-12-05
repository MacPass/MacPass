//
//  DDHotKey+Coding.m
//  MacPass
//
//  Created by Michael Starke on 25/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "DDHotKey+MacPassAdditions.h"

#import "MPFlagsHelper.h"

#import <Carbon/Carbon.h>

@implementation DDHotKey (MPKeydata)

+ (instancetype)defaultHotKey {
  return [DDHotKey defaultHotKeyWithTask:nil];
}

+ (instancetype)defaultHotKeyWithTask:(DDHotKeyTask)task {
  return [[DDHotKey alloc] initWithKeyData:nil task:task];
}

- (instancetype)initWithKeyData:(NSData *)data {
  self = [self initWithKeyData:data task:nil];
  return self;
}

- (instancetype)initWithKeyData:(NSData *)data task:(DDHotKeyTask)task{
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

@implementation DDHotKey (MPValidation)

- (BOOL)isValid {
  NSEventModifierFlags flags = 0;
  switch(self.keyCode) {
    case  kVK_Command:
      flags = NSCommandKeyMask;
      break;
    case kVK_Shift:
    case kVK_RightShift:
      flags = NSShiftKeyMask;
      break;
    case kVK_Option:
    case kVK_RightOption:
      flags = NSAlternateKeyMask;
      break;
    case kVK_Control:
    case kVK_RightControl:
      flags = NSControlKeyMask;
      break;
  }
  BOOL missingModifier = self.modifierFlags == 0;
  BOOL onlyModifiers = MPIsFlagSetInOptions(flags, self.modifierFlags) || (self.modifierFlags != 0 && flags != 0);
  BOOL isInvalid = onlyModifiers || missingModifier;
  return !isInvalid;
}

@end

