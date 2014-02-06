//
//  MPAutotypeCommand.m
//  MacPass
//
//  Created by Michael Starke on 10/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeCommand.h"
#import "NSString+Commands.h"

#import <Carbon/Carbon.h>

NSString *const kMPAutotypeSymbolShift = @"+";
NSString *const kMPAutotypeSymbolControl = @"^";
NSString *const kMPAutotypeSymbolAlt = @"%";
NSString *const kMPAutotypeSymbolEnter = @"~";
NSString *const kMPAutptypeCommandEnter = @"{ENTER}";
NSString *const kMPAutotypeCommandTab = @"{TAB}";
NSString *const kMPAutotypeCommandUp = @"{UP}";
NSString *const kMPAutotypeCommandDown = @"{DOWN}";
NSString *const kMPAutotypeCommandLeft = @"{LEFT}";
NSString *const kMPAutotypeCommandRight = @"{RIGHT}";
NSString *const kMPAutotypeCommandDelete = @"{DELETE}";
NSString *const kMPAutotypeCommandHome = @"{HOME}";
NSString *const kMPAutotypeCommandEnd = @"{END}";
NSString *const kMPAutotypeCommandPageUp = @"{PGUP}";
NSString *const kMPAutotypeCommandPageDown = @"{PGDOWN}";
NSString *const kMPAutotypeCommandBackspace = @"{BACKSPACE}";
NSString *const kMPAutotypeCommandBackspaceShort = @"{BS}";
NSString *const kMPAutotypeCommandBackspaceMedium = @"{BKSP}";
NSString *const kMPAutotypeCommandBreak = @"{BREAK}";
NSString *const kMPAutotypeCommandCapsLock = @"{CAPSLOCK}";
NSString *const kMPAutotypeCommandEscape = @"{ESC}";
NSString *const kMPAutotypeCommandWindows = @"{WIN}";
NSString *const kMPAutotypeCommandLeftWindows = @"{LWIN}";
NSString *const kMPAutotypeCommandRightWindows = @"{RWIN}";
NSString *const kMPAutotypeCommandApps = @"{APPS}";
NSString *const kMPAutotypeCommandHelp = @"{HELP}";
NSString *const kMPAutotypeCommandNumlock = @"{NUMLOCK}";
NSString *const kMPAutotypeCommandPrintScreen = @"{PRTSC}";
NSString *const kMPAutotypeCommandScrollLock = @"{SCROLLLOCK}";
NSString *const kMPAutotypeCommandF1 = @"{F1}";

uint16_t const kMPUnknownKeyCode = UINT16_MAX;

/*
 Tab	{TAB}
 Enter	{ENTER} or ~
 Arrow Up	{UP}
 Arrow Down	{DOWN}
 Arrow Left	{LEFT}
 Arrow Right	{RIGHT}
 Insert	{INSERT} or {INS}
 Delete	{DELETE} or {DEL}
 
 Home	{HOME}
 End	{END}
 Page Up	{PGUP}
 Page Down	{PGDN}
 Backspace	{BACKSPACE}, {BS} or {BKSP}
 Break	{BREAK}
 Caps-Lock	{CAPSLOCK}
 Escape	{ESC}
 Windows Key	{WIN} (equ. to {LWIN})
 Windows Key: left, right	{LWIN}, {RWIN}
 Apps / Menu	{APPS}
 Help	{HELP}
 Numlock	{NUMLOCK}
 Print Screen	{PRTSC}
 Scroll Lock	{SCROLLLOCK}
 F1 - F16	{F1} - {F16}
 Numeric Keypad +	{ADD}
 Numeric Keypad -	{SUBTRACT}
 Numeric Keypad *	{MULTIPLY}
 Numeric Keypad /	{DIVIDE}
 Numeric Keypad 0 to 9	{NUMPAD0} to {NUMPAD9}
 Shift	+
 Ctrl	^
 Alt	%
 +	{+}
 ^	{^}
 %	{%}
 ~	{~}
 (, )	{(}, {)}
 [, ]	{[}, {]}
 {, }	{{}, {}}
 */

@implementation MPAutotypeCommand

+ (NSString *)stringForKey:(CGKeyCode)keyCode {
  TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
  CFDataRef layoutData = TISGetInputSourceProperty(currentKeyboard,kTISPropertyUnicodeKeyLayoutData);
  CFRelease(currentKeyboard);
  
  const UCKeyboardLayout *keyboardLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
  /*
   Fallback for non-unicode Keyboards taken from to SRKeyCodeTransformer.m
   Copyright 2006-2007 Contributors. All rights reserved.
   License: BSD
   Contributors: David Dauer, Jesper, Jamie Kirkpatrick
   */
  if(!keyboardLayout) {
    currentKeyboard = TISCopyCurrentASCIICapableKeyboardLayoutInputSource();
    layoutData = (CFDataRef)TISGetInputSourceProperty(currentKeyboard, kTISPropertyUnicodeKeyLayoutData);
    CFRelease(currentKeyboard);
  }
  
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
  NSString *localizedName = CFBridgingRelease(TISGetInputSourceProperty(currentKeyboard, kTISPropertyLocalizedName));
  
  if(keyboardCodeDictionary == nil) {
    /* Input source should not change that much while we are running */
    keyboardCodeDictionary = [[NSMutableDictionary alloc] initWithCapacity:2];
  }
  NSDictionary *charToCodeDict = keyboardCodeDictionary[localizedName];
  if(nil == keyboardCodeDictionary[localizedName]) {
    /* We need 128 places for this dict */
    charToCodeDict = [[NSMutableDictionary alloc] initWithCapacity:128];
    
    /* Loop through every keycode (0 - 127) to find its current mapping. */
    for(CGKeyCode keyCode = 0; keyCode < 128; ++keyCode) {
      NSString *string = [self stringForKey:keyCode];
      if(string != nil) {
        ((NSMutableDictionary *)charToCodeDict)[string] = @(keyCode);
      }
    }
    keyboardCodeDictionary[localizedName] = [[NSDictionary alloc] initWithDictionary:charToCodeDict];
  }
  /* Add mapping */
  /* Generate table of keycodes and characters. */
  
  NSString *singleCharacter = [[character substringToIndex:1] lowercaseString];
  if(charToCodeDict[singleCharacter]) {
    return [charToCodeDict[singleCharacter] integerValue];
  }
  return kMPUnknownKeyCode;
}

- (void)sendPressKey:(CGKeyCode)keyCode modifierFlags:(CGEventFlags)flags {
  CGEventRef pressKey = CGEventCreateKeyboardEvent (NULL, keyCode, YES);
  CGEventRef releaseKey = CGEventCreateKeyboardEvent (NULL, keyCode, NO);
  
  /* The modifer Masks might be set, reset them */
  CGEventSetFlags(pressKey,0);
  CGEventSetFlags(releaseKey, 0);
  /* Set the modifiers to the ones we want */
  CGEventSetFlags(pressKey,flags);
  CGEventSetFlags(releaseKey, flags);
  
  /* Send the event */
  CGEventPost(kCGSessionEventTap, pressKey);
  CGEventPost(kCGSessionEventTap, releaseKey);
  
  CFRelease(pressKey);
  CFRelease(releaseKey);
}

- (void)sendPasteKeyCode {
  CGKeyCode keyCode = [MPAutotypeCommand keyCodeForCharacter:@"V"];
  if(keyCode == kMPUnknownKeyCode) {
    return; // We did not find a mapping for "V"
  }
  [self sendPressKey:keyCode modifierFlags:kCGEventFlagMaskCommand];
}

- (void)execute {
  NSAssert(NO, @"Not Implemented");
}
@end
