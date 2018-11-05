//
//  MPKeyMapper.m
//  MacPass
//
//  Created by Michael Starke on 07.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

#define MPArrayCount(array) (sizeof(array) / sizeof(array[0]))

@implementation MPKeyMapper

+ (NSString *)stringForKey:(CGKeyCode)keyCode {
  return [self stringForModifiedKey:MPMakeModifiedKey(0, keyCode)];
}

+ (NSString *)stringForModifiedKey:(MPModifiedKey)modifiedKey {
  if(modifiedKey.keyCode == kMPUnknownKeyCode) {
    return nil;
  }
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
  if(modifiedKey.modifier & kCGEventFlagMaskCommand) {
    modifierKeyState |= ((cmdKey >> 8 ) & 0xFF);
  }
  if(modifiedKey.modifier & kCGEventFlagMaskShift) {
    modifierKeyState |= ((shiftKey >> 8) & 0xFF);
  }
  if(modifiedKey.modifier & kCGEventFlagMaskAlternate) {
    modifierKeyState |= ((optionKey >> 8) & 0xFF);
  }
  if(modifiedKey.modifier & kCGEventFlagMaskControl) {
    modifierKeyState |= ((controlKey >> 8) & 0xFF);
  }
  OSStatus success = 0;
  success = UCKeyTranslate(keyboardLayout,
                           modifiedKey.keyCode,
                           kUCKeyActionDisplay,
                           modifierKeyState,
                           LMGetKbdType(),
                           kUCKeyTranslateNoDeadKeysBit,
                           &keysDown,
                           sizeof(chars) / sizeof(chars[0]),
                           &realLength,
                           chars);
  return CFBridgingRelease(CFStringCreateWithCharacters(kCFAllocatorDefault, chars, realLength));
}

+ (MPModifiedKey)modifiedKeyForCharacter:(NSString *)character {
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
  NSDictionary<NSString *, NSValue *> *charToCodeDict = keyboardCodeDictionary[localizedName];
  
  if(nil == charToCodeDict) {
    /* Add mapping */
    static uint64_t modifierCombinations[] = {
      0,
      kCGEventFlagMaskShift,
      kCGEventFlagMaskAlternate,
      kCGEventFlagMaskCommand,
      (kCGEventFlagMaskShift | kCGEventFlagMaskAlternate),
      (kCGEventFlagMaskShift | kCGEventFlagMaskCommand),
      (kCGEventFlagMaskShift | kCGEventFlagMaskCommand | kCGEventFlagMaskAlternate),
    };
    NSMutableDictionary *tempCharToCodeDict = [[NSMutableDictionary alloc] initWithCapacity:128];
    
    /* Generate table of keycodes and characters. */
    /* Loop through every keycode (0 - 127) to find its current mapping. */
    /* Loop through every control key compbination for every virtual key */
    for(CGKeyCode keyCode = 0; keyCode < 128; ++keyCode) {
      for(int modifierIndex = 0; modifierIndex < MPArrayCount(modifierCombinations); modifierIndex++) {
        MPModifiedKey mKey = MPMakeModifiedKey(modifierCombinations[modifierIndex], keyCode);
        NSString *string = [self stringForModifiedKey:mKey];
        if(string != nil && string.length > 0 && nil == tempCharToCodeDict[string]) {
          tempCharToCodeDict[string] = [NSValue valueWithModifiedKey:mKey];
        }
      }
    }
    charToCodeDict = [[NSDictionary alloc] initWithDictionary:tempCharToCodeDict];
    keyboardCodeDictionary[localizedName] = charToCodeDict;
  }
  NSValue *result = charToCodeDict[character];
  if(!result) {
    return MPMakeModifiedKey(0, kMPUnknownKeyCode);
  }
  return result.modifiedKeyValue;
}

@end
