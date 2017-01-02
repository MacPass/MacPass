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
  
  UCKeyTranslate(keyboardLayout,
                 keyCode,
                 kUCKeyActionDisplay,
                 0,
                 LMGetKbdType(),
                 kUCKeyTranslateNoDeadKeysBit,
                 &keysDown,
                 sizeof(chars) / sizeof(chars[0]),
                 &realLength,
                 chars);
  
  return CFBridgingRelease(CFStringCreateWithCharacters(kCFAllocatorDefault, chars, 1));
}

+ (CGKeyCode)keyCodeForCharacter:(NSString *)character {
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
  NSDictionary<NSString *, NSNumber *> *charToCodeDict = keyboardCodeDictionary[localizedName];

  if(nil == charToCodeDict) {
    /* Add mapping */
    NSMutableDictionary *tempCharToCodeDict = [[NSMutableDictionary alloc] initWithCapacity:128];
    
    /* Generate table of keycodes and characters. */
    /* Loop through every keycode (0 - 127) to find its current mapping. */
    for(CGKeyCode keyCode = 0; keyCode < 128; ++keyCode) {
      NSString *string = [self stringForKey:keyCode];
      if(string != nil) {
        tempCharToCodeDict[string] = @(keyCode);
      }
    }
    charToCodeDict = [[NSDictionary alloc] initWithDictionary:tempCharToCodeDict];
    keyboardCodeDictionary[localizedName] = charToCodeDict;
  }
  NSString *singleCharacter = [character substringToIndex:1].lowercaseString;
  if(charToCodeDict[singleCharacter]) {
    return charToCodeDict[singleCharacter].integerValue;
  }
  return kMPUnknownKeyCode;
}

@end
