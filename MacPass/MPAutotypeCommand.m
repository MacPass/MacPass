//
//  MPAutotypeCommand.m
//  MacPass
//
//  Created by Michael Starke on 10/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
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

#import "MPAutotypeCommand.h"

#import "MPAutotypePaste.h"
#import "MPAutotypeKeyPress.h"
#import "MPAutotypeClear.h"
#import "MPAutotypeDelay.h"

#import "MPAutotypeContext.h"
#import "MPKeyMapper.h"

#import "KeePassKit/KeePassKit.h"

#import <Carbon/Carbon.h>
#import <CommonCrypto/CommonCrypto.h>

static CGKeyCode kMPFunctionKeyCodes[] = {
  kVK_F1,
  kVK_F2,
  kVK_F3,
  kVK_F4,
  kVK_F5,
  kVK_F6,
  kVK_F7,
  kVK_F8,
  kVK_F9,
  kVK_F10,
  kVK_F11,
  kVK_F12,
  kVK_F13,
  kVK_F14,
  kVK_F15,
  kVK_F16,
  kVK_F17,
  kVK_F18,
  kVK_F19
};

static CGKeyCode kMPNumpadKeyCodes[] = {
  kVK_ANSI_Keypad0,
  kVK_ANSI_Keypad1,
  kVK_ANSI_Keypad2,
  kVK_ANSI_Keypad3,
  kVK_ANSI_Keypad4,
  kVK_ANSI_Keypad5,
  kVK_ANSI_Keypad6,
  kVK_ANSI_Keypad7,
  kVK_ANSI_Keypad8,
  kVK_ANSI_Keypad9
};

@interface NSNumber (AutotypeCommand)

@property (nonatomic, readonly, assign) CGEventFlags eventFlagsValue;
@property (nonatomic, readonly, assign) CGKeyCode keyCodeValue;

@end

@implementation NSNumber (AutotypeCommand)

- (CGEventFlags)eventFlagsValue {
  return (CGEventFlags)self.integerValue;
}
- (CGKeyCode)keyCodeValue {
  return (CGKeyCode)self.integerValue;
}

@end

@interface MPAutotypeParserContext : NSObject

@property (strong) NSMutableArray *commands;
@property (copy) NSString *commandString;
@property (assign) CGEventFlags activeModifiers;
@property (assign) BOOL obfuscate;

- (instancetype)initWithString:(NSString *)commandString modifiers:(CGEventFlags)modifiers commands:(NSMutableArray *)commands;

@end

@implementation MPAutotypeParserContext

- (instancetype)initWithString:(NSString *)commandString modifiers:(CGEventFlags)modifiers commands:(NSMutableArray *)commands {
  self = [super init];
  if(self) {
    _commands = commands;
    _commandString = [commandString copy];
    _activeModifiers = modifiers;
  }
  return self;
}

@end

@implementation MPAutotypeCommand

+ (NSDictionary *)_keypressCommands {
  static NSDictionary *keypressCommands;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    keypressCommands = @{ kKPKAutotypeBackspace : @(kVK_Delete),
                          //kKPKAutotypeBreak : @0,
                          kKPKAutotypeCapsLock : @(kVK_CapsLock),
                          kKPKAutotypeDelete : @(kVK_ForwardDelete),
                          kKPKAutotypeDown : @(kVK_DownArrow),
                          kKPKAutotypeEnd : @(kVK_End),
                          kKPKAutotypeEnter : @(kVK_Return),
                          kKPKAutotypeEscape : @(kVK_Escape),
                          kKPKAutotypeHelp : @(kVK_Help),
                          kKPKAutotypeHome : @(kVK_Home),
                          //kKPKAutotypeInsert : @(),
                          kKPKAutotypeLeft : @(kVK_LeftArrow),
                          kKPKAutotypeLeftWindows : @(kVK_Command),
                          //kKPKAutotypeNumlock : @(),
                          kKPKAutotypePageDown : @(kVK_PageDown),
                          kKPKAutotypePageUp : @(kVK_PageUp),
                          //kKPKAutotypePrintScreen : @(),
                          kKPKAutotypeRight : @(kVK_RightArrow),
                          kKPKAutotypeRightWindows : @(kVK_Command),
                          //kKPKAutotypeScrollLock : @(),
                          kKPKAutotypeSpace : @(kVK_Space),
                          kKPKAutotypeTab : @(kVK_Tab),
                          kKPKAutotypeUp : @(kVK_UpArrow),
                          kKPKAutotypeWindows : @(kVK_Command)
                          };
  });
  return keypressCommands;
}
/* Commands that are actually just one symbol to be pasted */
+ (NSDictionary *)_characterCommands {
  static NSDictionary *characterCommands;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    characterCommands = @{
                          kKPKAutotypePlus: @"+",
                          kKPKAutotypeCaret: @"^",
                          kKPKAutotypePercent: @"%",
                          kKPKAutotypeTilde : @"~",
                          kKPKAutotypeRoundBracketLeft : @"(",
                          kKPKAutotypeRoundBracketRight : @")",
                          kKPKAutotypeSquareBracketLeft : @"[",
                          kKPKAutotypeSquareBracketRight : @"]",
                          kKPKAutotypeCurlyBracketLeft: @"{",
                          kKPKAutotypeCurlyBracketRight: @"}"
                          };
  });
  return characterCommands;
}

/**
 *  Mapping for modifier to CGEventFlags.
 *
 *  @return dictionary with commands as keys and CGEventFlags as wrapped values
 */
+ (NSDictionary *)_modifierCommands {
  static NSDictionary *modifierCommands;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    modifierCommands = @{
                         kKPKAutotypeAlt : @(kCGEventFlagMaskAlternate),
                         kKPKAutotypeControl : @(kCGEventFlagMaskControl),
                         kKPKAutotypeShift : @(kCGEventFlagMaskShift)
                         };
  });
  return modifierCommands;
}

+ (NSArray *)commandsForContext:(MPAutotypeContext *)context {
  if(!context.valid) {
    return nil;
  }
  NSUInteger reserverd = MAX(1,context.normalizedCommand.length / 4);
  NSMutableArray *commands = [[NSMutableArray alloc] initWithCapacity:reserverd];
  NSMutableArray __block *commandRanges = [[NSMutableArray alloc] initWithCapacity:reserverd];
  NSRegularExpression *commandRegExp = [[NSRegularExpression alloc] initWithPattern:@"\\{[^\\{\\}]+\\}" options:NSRegularExpressionCaseInsensitive error:0];
  NSAssert(commandRegExp, @"RegExp is constant. Has to work all the time");
  [commandRegExp enumerateMatchesInString:context.evaluatedCommand options:0 range:NSMakeRange(0, context.evaluatedCommand.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
    @autoreleasepool {
      [commandRanges addObject:[NSValue valueWithRange:result.range]];
    }
  }];
  
  /* add range at the end as terminator */
  [commandRanges addObject:[NSValue valueWithRange:NSMakeRange(context.evaluatedCommand.length, 0)]];
  
  NSUInteger location = 0;
  CGEventFlags modifiers = 0;
  
  for(NSValue *rangeValue in commandRanges) {
    NSRange commandRange = rangeValue.rangeValue;
    /* All non-commands will get translated into key presses if possible, otherwiese into paste commands */
    if(location < commandRange.location) {
      /* If there were modifiers we need to use the next single stroke and update the modifier command */
      if(modifiers) {
        NSString *modifiedKey = [context.evaluatedCommand substringWithRange:NSMakeRange(location, 1)];
        MPAutotypeKeyPress *press = [[MPAutotypeKeyPress alloc] initWithModifierMask:modifiers character:modifiedKey];
        if(press) {
          [commands addObject:press];
        }
        modifiers = 0;
        location++;
      }
      NSRange textRange = NSMakeRange(location, commandRange.location - location);
      if(textRange.length > 0) {
        NSString *textValue = [context.evaluatedCommand substringWithRange:textRange];
        [self _appendTextCommandWithContent:textValue toCommands:commands obfusctate:context.entry.autotype.obfuscateDataTransfer];
      }
    }
    /* Test for modifer Key */
    NSString *commandString = [context.evaluatedCommand substringWithRange:commandRange];
    /* append commands for non-modifer keys */
    if(![self _updateModifierMask:&modifiers forCommand:commandString]) {
      [self _appendCommandForString:commandString toCommands:commands activeModifer:modifiers obfuscate:context.entry.autotype.obfuscateDataTransfer];
      modifiers = 0; // Reset the modifers;
    }
    location = commandRange.location + commandRange.length;
  }
  return commands;
}

+ (void)_appendTextCommandWithContent:(NSString *)pasteContent toCommands:(NSMutableArray *)commands obfusctate:(BOOL)obfuscate {
  if(obfuscate) {
    [self _appendObfuscatedPasteCommandForContent:pasteContent toCommands:commands];
  }
  else {
    MPAutotypePaste *pasteCommand = [[MPAutotypePaste alloc] initWithString:pasteContent];
    [commands addObject:pasteCommand];
  }
}

+ (void)_appendObfuscatedPasteCommandForContent:(NSString *)pasteContent toCommands:(NSMutableArray *)commands {
  if(!pasteContent) {
    return;
  }
  @autoreleasepool {
    /*
     * obfuscate entered data using Two-Channel Auto-Type Obfuscation
     * refer to KeePass documentation for more information
     * http://keepass.info/help/v2/autotype_obfuscation.html
     */
    
    NSMutableString *paste = [@"" mutableCopy];
    NSMutableArray<NSValue *> *typeKeys = [[NSMutableArray alloc] init];
    
    /*
     * seed the random number generator using the first 4 bytes of the string's SHA1
     * this ensures that you get the same string split every time for a given string
     */
    const char *cstr = [pasteContent cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:pasteContent.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    srandom(*((unsigned int*)digest));
    
    for (NSUInteger i = 0; i < pasteContent.length; i++) {
      NSUInteger part = random() % 2;
      
      NSString *key = [pasteContent substringWithRange:NSMakeRange(i, 1)];
      MPModifiedKey mKey = [MPKeyMapper modifiedKeyForCharacter:key];
      /* append unknown keycodes to the paste since we can't type them */
      if (part == 0 || mKey.keyCode == kMPUnknownKeyCode) {
        [paste appendString:key];
        [typeKeys addObject:[NSValue valueWithModifiedKey:MPMakeModifiedKey(0, kVK_RightArrow)]];
      }
      else {
        [typeKeys addObject:[NSValue valueWithModifiedKey:mKey ]];
      }
    }
    
    /* move to the end of the content */
    for (NSUInteger i = typeKeys.count; i < pasteContent.length; i++) {
      [typeKeys addObject:[NSValue valueWithModifiedKey:MPMakeModifiedKey(0, kVK_RightArrow)]];
    }
    
    /* add paste command */
    MPAutotypePaste *pasteCommand = [[MPAutotypePaste alloc] initWithString:paste];
    [commands addObject:pasteCommand];
    
    /* add keypress commands */
    if(typeKeys.count > 0) {
      for(NSUInteger i = 0; i < paste.length; i++) {
        [commands addObject:[[MPAutotypeKeyPress alloc] initWithModifiedKey:MPMakeModifiedKey(0, kVK_LeftArrow)]];
      }
      for(NSUInteger i = 0; i < typeKeys.count; i++) {
        [commands addObject:[[MPAutotypeKeyPress alloc] initWithModifiedKey:typeKeys[i].modifiedKeyValue]];
      }
    }
  }
}

+ (void)_appendCommandForString:(NSString *)commandString toCommands:(NSMutableArray *)commands activeModifer:(CGEventFlags)flags obfuscate:(BOOL)obfuscate {
  if(!commandString || !commandString.length) {
    return;
  }
  /* Simple Special Press */
  NSString *uppercaseCommand = commandString.uppercaseString;
  NSNumber *keyCodeNumber = [self _keypressCommands][uppercaseCommand];
  if(nil != keyCodeNumber) {
    MPAutotypeKeyPress *press = [[MPAutotypeKeyPress alloc] initWithModifiedKey:MPMakeModifiedKey(flags, keyCodeNumber.keyCodeValue)];
    if(press) {
      [commands addObject:press];
    }
    return; // Done
  }
  /* {PLUS}, {TILDE}, {PERCENT}, {+}, etc */
  NSString *character = [self _characterCommands][uppercaseCommand];
  if(character) {
    MPAutotypeKeyPress *press = [[MPAutotypeKeyPress alloc] initWithModifierMask:flags character:character];
    if(press) {
      [commands addObject:press];
    }
    return; // Done
  }
  
  /* F1-16 */
  NSRegularExpression *functionKeyRegExp = [[NSRegularExpression alloc] initWithPattern:kKPKAutotypeFunctionMaskRegularExpression options:NSRegularExpressionCaseInsensitive error:0];
  NSTextCheckingResult *functionResult = [functionKeyRegExp firstMatchInString:commandString options:0 range:NSMakeRange(0, commandString.length)];
  if(functionResult && functionResult.numberOfRanges == 2) {
    NSString *numberString = [commandString substringWithRange:[functionResult rangeAtIndex:1]];
    NSScanner *numberScanner = [[NSScanner alloc] initWithString:numberString];
    NSInteger functionNumber = 0;
    if([numberScanner scanInteger:&functionNumber] && functionNumber >= 1 && functionNumber <= 19) {
      MPAutotypeKeyPress *press = [[MPAutotypeKeyPress alloc] initWithModifiedKey:MPMakeModifiedKey(flags, kMPFunctionKeyCodes[functionNumber-1])];
      if(press) {
        [commands addObject:press];
      }
      return; // Done
    }
  }
  
  /* Numpad0-9 */
  NSRegularExpression *numpadKeyRegExp = [[NSRegularExpression alloc] initWithPattern:kKPKAutotypeKeypaddNumberMaskRegularExpression options:NSRegularExpressionCaseInsensitive error:0];
  NSTextCheckingResult *numpadResult = [numpadKeyRegExp firstMatchInString:commandString options:0 range:NSMakeRange(0, commandString.length)];
  if(numpadResult && numpadResult.numberOfRanges == 2) {
    NSString *numberString = [commandString substringWithRange:[numpadResult rangeAtIndex:1]];
    NSScanner *numberScanner = [[NSScanner alloc] initWithString:numberString];
    NSInteger numpadNumber = 0;
    if([numberScanner scanInteger:&numpadNumber] && numpadNumber >= 0 && numpadNumber <= 9) {
      MPAutotypeKeyPress *press = [[MPAutotypeKeyPress alloc] initWithModifiedKey:MPMakeModifiedKey(flags, kMPNumpadKeyCodes[numpadNumber])];
      if(press) {
        [commands addObject:press];
      }
      return; // Done
    }
  }
  
  /* Clearfield */
  if([kKPKAutotypeClearField isEqualToString:uppercaseCommand]) {
    [commands addObject:[[MPAutotypeClear alloc] init]];
    return; // Done
  }
  // TODO: add {APPLICATION <appname>}
  /* Delay */
  NSString *delayPattern = [[NSString alloc] initWithFormat:@"\\{(%@|%@)[ |=]+([0-9]+)\\}",
                            kKPKAutotypeDelay,
                            kKPKAutotypeVirtualKey/*,
                                                   kKPKAutotypeVirtualExtendedKey,
                                                   kKPKAutotypeVirtualNonExtendedKey*/];
  NSRegularExpression *delayRegExp = [[NSRegularExpression alloc] initWithPattern:delayPattern options:NSRegularExpressionCaseInsensitive error:0];
  NSAssert(delayRegExp, @"Regex for delay should work!");
  NSTextCheckingResult *result = [delayRegExp firstMatchInString:commandString options:0 range:NSMakeRange(0, commandString.length)];
  if(result && (result.numberOfRanges == 3)) {
    NSString *uppercaseCommand = [[commandString substringWithRange:[result rangeAtIndex:1]] uppercaseString];
    NSString *valueString = [commandString substringWithRange:[result rangeAtIndex:2]];
    NSScanner *numberScanner = [[NSScanner alloc] initWithString:valueString];
    NSInteger value;
    if([numberScanner scanInteger:&value]) {
      if([kKPKAutotypeDelay isEqualToString:uppercaseCommand]) {
        if(MAX(0, value) <= 0) {
          return; // Value too low, just skipp
        }
        [commands addObject:[[MPAutotypeDelay alloc] initWithDelay:value]];
        return; // Done
      }
      else if([kKPKAutotypeVirtualKey isEqualToString:uppercaseCommand]) {
        NSLog(@"Virtual key strokes aren't supported yet!");
        // TODO add key
      }
    }
    else {
      NSLog(@"Unable to parse value part in command:%@", commandString);
    }
  }
  else {
    /* Fallback */
    [self _appendTextCommandWithContent:commandString toCommands:commands obfusctate:obfuscate];
  }
}

+ (BOOL)_updateModifierMask:(CGEventFlags *)mask forCommand:(NSString *)commandString {
  NSAssert(mask != NULL, @"Input pointer missing!");
  if(mask == NULL) {
    return NO;
  }
  NSNumber *flagNumber = [self _modifierCommands][commandString.uppercaseString];
  if(!flagNumber) {
    return NO; // No modifier key, just leave
  }
  CGEventFlags flags = flagNumber.eventFlagsValue;
  *mask |= flags;
  return YES;
}

- (void)sendPressKey:(MPModifiedKey)key {
  [self sendPressKey:key.keyCode modifierFlags:key.modifier];
}

- (void)sendPressKey:(CGKeyCode)keyCode modifierFlags:(CGEventFlags)flags {
  
  CGEventSourceRef eventSource = CGEventSourceCreate(kCGEventSourceStatePrivate);
  if(NULL == eventSource) {
    return; // We could not create our own source, abort!
  }
  CGEventRef pressKey = CGEventCreateKeyboardEvent (eventSource, keyCode, YES);
  CGEventRef releaseKey = CGEventCreateKeyboardEvent (eventSource, keyCode, NO);
  
  /*
   Set the modifiers to the ones we want
   We use our private event source so no modifier reset should be needed
   */
  CGEventSetFlags(pressKey, flags);
  CGEventSetFlags(releaseKey, flags);
  
  /* Send the event */
  CGEventPost(kCGHIDEventTap, pressKey);
  usleep(0.05 * NSEC_PER_MSEC);
  CGEventPost(kCGHIDEventTap, releaseKey);
  
  CFRelease(pressKey);
  CFRelease(releaseKey);
  CFRelease(eventSource);
}

- (void)sendPasteKeyCode {
  MPModifiedKey mKey = [MPKeyMapper modifiedKeyForCharacter:@"v"];
  if(mKey.keyCode == kMPUnknownKeyCode) {
    return; // We did not find a mapping for "V"
  }
  [self sendPressKey:mKey.keyCode modifierFlags:kCGEventFlagMaskCommand];
}

- (void)execute {
  NSAssert(NO, @"Not Implemented");
}

- (BOOL)isValid {
  return NO; // No valid command
}

@end
