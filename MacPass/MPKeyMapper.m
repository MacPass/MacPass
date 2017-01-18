//
//  MPKeyMapper.m
//  MacPass
//
//  Created by Michael Starke on 07.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//
//  Uses Code from:
//  SRKeyCodeTransformer.h
//  ShortcutRecorder
//
//  Copyright 2006-2007 Contributors. All rights reserved.
//
//  License: BSD
//
//  Contributors:
//      David Dauer
//      Jesper
//      Jamie Kirkpatrick


#import "MPKeyMapper.h"

#import <Carbon/Carbon.h>

uint16_t const kMPUnknownKeyCode = UINT16_MAX;

@implementation MPKeyMapper

+ (NSString *)stringForKey:(CGKeyCode)keyCode {
  return [self stringForKey:keyCode modifier:0];
}

+ (NSString *)stringForKey:(CGKeyCode)keyCode modifier:(CGEventFlags)modifier {
  TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
  CFDataRef layoutData = TISGetInputSourceProperty(currentKeyboard,kTISPropertyUnicodeKeyLayoutData);
  
  if(!layoutData) {
    currentKeyboard = TISCopyCurrentASCIICapableKeyboardLayoutInputSource();
    layoutData = (CFDataRef)TISGetInputSourceProperty(currentKeyboard, kTISPropertyUnicodeKeyLayoutData);
  }
  CFRelease(currentKeyboard);
  
  const UCKeyboardLayout *keyboardLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
  
  UInt32 keysDown = 0;
  UniChar chars[4];
  UniCharCount realLength;
  
  
  uint32_t modifierKeyState = 0;
  if(modifier & kCGEventFlagMaskCommand) {
    modifierKeyState |= ((cmdKey >> 8 ) & 0xFF);
  }
  if(modifier & kCGEventFlagMaskShift) {
    modifierKeyState |= ((shiftKey >> 8) & 0xFF);
  }
  if(modifier & kCGEventFlagMaskAlternate) {
    modifierKeyState |= ((optionKey >> 8) & 0xFF);
  }
  if(modifier & kCGEventFlagMaskControl) {
    modifierKeyState |= ((controlKey >> 8) & 0xFF);
  }
  OSStatus success = 0;
  success = UCKeyTranslate(keyboardLayout,
                           keyCode,
                           kUCKeyActionDisplay,
                           modifierKeyState,
                           LMGetKbdType(),
                           kUCKeyTranslateNoDeadKeysBit,
                           &keysDown,
                           sizeof(chars) / sizeof(chars[0]),
                           &realLength,
                           chars);
  
  return CFBridgingRelease(CFStringCreateWithCharacters(kCFAllocatorDefault, chars, 1));
}

+ (CGKeyCode)keyCodeForCharacter:(NSString *)character modifier:(CGEventFlags *)modifer {
  static NSMutableDictionary *keyboardCodeDictionary;
  
  TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
  NSString *localizedName = (__bridge NSString *)TISGetInputSourceProperty(currentKeyboard, kTISPropertyLocalizedName);
  CFRelease(currentKeyboard);
  
  /* Initalize the keyboardCodeDictonary */
  if(keyboardCodeDictionary == nil) {
    /* Input source should not change that much while we are running */
    keyboardCodeDictionary = [[NSMutableDictionary alloc] initWithCapacity:2];
  }
  /* search for current character mapping */
  NSDictionary<NSString *, NSArray<NSNumber *> *> *charToCodeDict = keyboardCodeDictionary[localizedName];
  
  if(nil == charToCodeDict) {
    /* Add mapping */
    NSMutableDictionary *tempCharToCodeDict = [[NSMutableDictionary alloc] initWithCapacity:128];
    
    /* Generate table of keycodes and characters. */
    /* Loop through every keycode (0 - 127) to find its current mapping. */
    /* Loop throuhg every control key compbination for every virutal key */
    for(CGKeyCode keyCode = 0; keyCode < 128; ++keyCode) {
      uint64_t modifiers[] = { 0, kCGEventFlagMaskShift, kCGEventFlagMaskAlternate, kCGEventFlagMaskControl, kCGEventFlagMaskShift | kCGEventFlagMaskAlternate,  kCGEventFlagMaskShift | kCGEventFlagMaskControl, kCGEventFlagMaskShift | kCGEventFlagMaskAlternate | kCGEventFlagMaskControl };
      for(int modifierIndex = 0; modifierIndex < sizeof(modifiers); modifierIndex++) {
        NSString *string = [self stringForKey:keyCode modifier:modifiers[modifierIndex]];
        if(string != nil && string.length > 0 && nil == tempCharToCodeDict[string]) {
          tempCharToCodeDict[string] = @[@(keyCode), @(modifiers[modifierIndex])];
        }
      }
    }
    charToCodeDict = [[NSDictionary alloc] initWithDictionary:tempCharToCodeDict];
    keyboardCodeDictionary[localizedName] = charToCodeDict;
  }
  NSString *singleCharacter = [character substringToIndex:1].lowercaseString;
  NSArray<NSNumber *> *result = charToCodeDict[singleCharacter];
  if(result) {
    if(modifer) {
      *modifer = result[1].unsignedIntegerValue;
    }
    /* false positive when no modifier was supplied! */
    return result[0].integerValue;
  }
  if(modifer) {
    *modifer = 0;
  }
  return kMPUnknownKeyCode;
}

@end
