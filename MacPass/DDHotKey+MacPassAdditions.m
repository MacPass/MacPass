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

+ (NSData *)hotKeyDataWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags {
  NSMutableData *data = [[NSMutableData alloc] init];
  NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  [archiver encodeInt:keyCode forKey:NSStringFromSelector(@selector(keyCode))];
  [archiver encodeInteger:flags forKey:NSStringFromSelector(@selector(modifierFlags))];
  [archiver finishEncoding];
  return [data copy];
}

+ (NSData *)defaultHotKeyData {
  return [self hotKeyDataWithKeyCode:kVK_ANSI_M modifierFlags:kCGEventFlagMaskControl|kCGEventFlagMaskAlternate];
}

+ (instancetype)defaultHotKey {
  return [DDHotKey defaultHotKeyWithTask:nil];
}

+ (instancetype)defaultHotKeyWithTask:(DDHotKeyTask)task {
  return [DDHotKey hotKeyWithKeyData:nil task:task];
}

+ (instancetype)hotKeyWithKeyData:(NSData *)data {
  return [self hotKeyWithKeyData:data task:nil];
}

+ (instancetype)hotKeyWithKeyData:(NSData *)data task:(DDHotKeyTask)task {
  NSUInteger modifierFlags;
  unsigned short keyCode;
  if(!data) {
    return [DDHotKey hotKeyWithKeyCode:kVK_ANSI_M modifierFlags:kCGEventFlagMaskControl|kCGEventFlagMaskAlternate task:task];
  }
  if([self _getKeyCode:&keyCode modifierFlags:&modifierFlags fromData:data]) {
    return [DDHotKey hotKeyWithKeyCode:keyCode modifierFlags:modifierFlags task:task];
  }
  return nil;
}

- (NSData *)keyData {
  return [self.class hotKeyDataWithKeyCode:self.keyCode modifierFlags:self.modifierFlags];
}

+ (BOOL)_getKeyCode:(unsigned short *)keyCode modifierFlags:(NSUInteger *)modifierFlags fromData:(NSData *)data {
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

