//
//  MPAutotypeCommand.m
//  MacPass
//
//  Created by Michael Starke on 10/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeCommand.h"

#import "MPAutotypePaste.h"
#import "MPAutotypeKeyPress.h"
#import "MPAutotypeClear.h"
#import "MPAutotypeDelay.h"

#import "MPAutotypeContext.h"
#import "MPKeyMapper.h"

#import "KPKEntry.h"
#import "KPKAutotype.h"
#import "KPKAutotypeCommands.h"

#import "NSString+Commands.h"

#import <Carbon/Carbon.h>

#import <CommonCrypto/CommonCrypto.h>

static CGKeyCode kMPFunctionKeyCodes[] = { kVK_F1, kVK_F2, kVK_F3, kVK_F4, kVK_F5, kVK_F6, kVK_F7, kVK_F8, kVK_F9, kVK_F10, kVK_F11, kVK_F12, kVK_F13, kVK_F14, kVK_F15, kVK_F16, kVK_F17, kVK_F18, kVK_F19 };

@interface NSNumber (AutotypeCommand)

- (CGEventFlags)eventFlagsValue;
- (CGKeyCode)keyCodeValue;

@end

@implementation NSNumber (AutotypeCommand)

- (CGEventFlags)eventFlagsValue {
  return (CGEventFlags)[self integerValue];
}
- (CGKeyCode)keyCodeValue {
  return (CGKeyCode)[self integerValue];
}

@end

@implementation MPAutotypeCommand

+ (NSDictionary *)keypressCommands {
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

/**
 *  Mapping for modifier to CGEventFlags.
 *  @note KeepassControl is mapped to command!
 *
 *  @return dictionary with commands as keys and CGEventFlags as wrapped values
 */
+ (NSDictionary *)modifierCommands {
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
  if(![context isValid]) {
    return nil;
  }
  NSUInteger reserverd = MAX(1,[context.normalizedCommand length] / 4);
  NSMutableArray *commands = [[NSMutableArray alloc] initWithCapacity:reserverd];
  NSMutableArray __block *commandRanges = [[NSMutableArray alloc] initWithCapacity:reserverd];
  NSRegularExpression *commandRegExp = [[NSRegularExpression alloc] initWithPattern:@"\\{[^\\{\\}]+\\}" options:NSRegularExpressionCaseInsensitive error:0];
  NSAssert(commandRegExp, @"RegExp is constant. Has to work all the time");
  [commandRegExp enumerateMatchesInString:context.evaluatedCommand options:0 range:NSMakeRange(0, [context.evaluatedCommand length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
    @autoreleasepool {
      [commandRanges addObject:[NSValue valueWithRange:result.range]];
    }
  }];
  NSUInteger lastLocation = 0;
  CGEventFlags collectedModifers = 0;
  for(NSValue *rangeValue in commandRanges) {
    NSRange commandRange = [rangeValue rangeValue];
    /* All non-commands will get translated into paste commands */
    if(commandRange.location > lastLocation) {
      /* If there were modifiers we need to use the next single stroke and update the modifier command */
      if(collectedModifers) {
        NSString *modifiedKey = [context.evaluatedCommand substringWithRange:NSMakeRange(lastLocation, 1)];
        MPAutotypeKeyPress *press = [[MPAutotypeKeyPress alloc] initWithModifierMask:collectedModifers character:modifiedKey];
        if(press) {
          [commands addObject:press];
        }
        collectedModifers = 0;
        lastLocation++;
      }
      NSRange pasteRange = NSMakeRange(lastLocation, commandRange.location - lastLocation);
      if(pasteRange.length > 0) {
        NSString *pasteValue = [context.evaluatedCommand substringWithRange:pasteRange];
        [self appendAppropriatePasteCommandForEntry:context.entry withContent:pasteValue toCommands:commands];
      }
    }
    /* Test for modifer Key */
    NSString *commandString = [context.evaluatedCommand substringWithRange:commandRange];
    /* append commands for non-modifer keys */
    if(![self updateModifierMask:&collectedModifers forCommand:commandString]) {
      [self appendCommandForEntry:context.entry withString:commandString toCommands:commands activeModifer:collectedModifers];
      collectedModifers = 0; // Reset the modifers;
    }
    lastLocation = commandRange.location + commandRange.length;
  }
  /* Collect any part that isn't a command or if onyl paste is used */
  if(lastLocation < [context.evaluatedCommand length]) {
    /* We might have some dangling modifiers */
    NSRange lastRange = NSMakeRange(lastLocation, [context.evaluatedCommand length] - lastLocation);
    if(lastRange.length > 0) {
      NSString *modifiedKey = [context.evaluatedCommand substringWithRange:NSMakeRange(lastLocation, 1)];
      MPAutotypeKeyPress *press = [[MPAutotypeKeyPress alloc] initWithModifierMask:collectedModifers character:modifiedKey];
      if(press) {
        [commands addObject:press];
      }
      if(lastRange.length > 1) {
        NSRange pasteRange = NSMakeRange(lastRange.location + 1, lastRange.length - 1);
        NSString *pasteValue = [context.evaluatedCommand substringWithRange:pasteRange];
        [self appendAppropriatePasteCommandForEntry:context.entry withContent:pasteValue toCommands:commands];
      }
    }
  }
  return commands;
}

+ (void)appendAppropriatePasteCommandForEntry:(KPKEntry *)entry withContent:(NSString *)pasteContent toCommands:(NSMutableArray *)commands
{
  if (entry.autotype.obfuscateDataTransfer)
    [self appendObfuscatedPasteCommandForContent:pasteContent toCommands:commands];
  else
    [self appendPasteCommandForContent:pasteContent toCommands:commands];
}

+ (void)appendPasteCommandForContent:(NSString *)pasteContent toCommands:(NSMutableArray *)commands {
  /* Update an already inserted paste command with the new conents */
  if([[commands lastObject] isKindOfClass:[MPAutotypePaste class]]) {
    [[commands lastObject] appendString:pasteContent];
  }
  else {
    MPAutotypePaste *pasteCommand = [[MPAutotypePaste alloc] initWithString:pasteContent];
    [commands addObject:pasteCommand];
  }
}

+ (void)appendObfuscatedPasteCommandForContent:(NSString *)pasteContent toCommands:(NSMutableArray *)commands {
  if(pasteContent) {
    
    /*
     * obfuscate entered data using Two-Channel Auto-Type Obfuscation
     * refer to KeePass documentation for more information
     * http://keepass.info/help/v2/autotype_obfuscation.html
     */
    
    NSString *paste = @"";
    NSMutableArray *typeKeys = [NSMutableArray array];
    NSMutableArray *modifiers = [NSMutableArray array];
    
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
      
      unichar key = [pasteContent characterAtIndex:i];
      CGKeyCode keyCode = [MPKeyMapper keyCodeForCharacter:[NSString stringWithFormat:@"%c", key]];
      
      /* append unknown keycodes to the paste since we can't type them */
      if (part == 0 || keyCode == kMPUnknownKeyCode) {
        paste = [paste stringByAppendingFormat:@"%c", key];
        
        [typeKeys addObject:@(kVK_RightArrow)];
        [modifiers addObject:@0];
      }
      else {
        [typeKeys addObject:@(keyCode)];
        
        if ([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:key])
          [modifiers addObject:@(kCGEventFlagMaskShift)];
        else
          [modifiers addObject:@0];
      }
    }
    
    /* move to the end of the content */
    for (NSUInteger i = typeKeys.count; i < pasteContent.length; i++) {
      [typeKeys addObject:@(kVK_RightArrow)];
      [modifiers addObject:@0];
    }
    
    /* add paste command */
    MPAutotypePaste *pasteCommand = [[MPAutotypePaste alloc] initWithString:paste];
    [commands addObject:pasteCommand];
    
    /* add keypress commands */
    if (typeKeys.count > 0) {
      for (NSUInteger i = 0; i < paste.length; i++) {
        [commands addObject:[[MPAutotypeKeyPress alloc] initWithModifierMask:0 keyCode:kVK_LeftArrow]];
      }
      
      for (NSUInteger i = 0; i < typeKeys.count; i++) {
        [commands addObject:[[MPAutotypeKeyPress alloc] initWithModifierMask:[modifiers[i] longLongValue] keyCode:[typeKeys[i] unsignedShortValue]]];
      }
    }
  }
}

+ (void)appendCommandForEntry:(KPKEntry *)entry withString:(NSString *)commandString toCommands:(NSMutableArray *)commands activeModifer:(CGEventFlags)flags {
  if(nil == commandString) {
    return; // Nothing to parse
  }
  /* Simple Special Press */
  NSString *uppercaseCommand = commandString.uppercaseString;
  NSNumber *keyCodeNumber = [self keypressCommands][uppercaseCommand];
  if(nil != keyCodeNumber) {
    CGKeyCode keyCode = [keyCodeNumber keyCodeValue];
    [commands addObject:[[MPAutotypeKeyPress alloc] initWithModifierMask:flags keyCode:keyCode]];
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
      [commands addObject:[[MPAutotypeKeyPress alloc] initWithModifierMask:flags keyCode:kMPFunctionKeyCodes[functionNumber-1]]];
      return; // Done
    }
  }
  /* Numpad 0-9 */
  /* TODO: Numpad is not invariant, mapping is needed */
  
  /* Clearfield */
  if([kKPKAutotypeClearField isEqualToString:uppercaseCommand]) {
    [commands addObject:[[MPAutotypeClear alloc] init]];
    return; // Done
  }
  // TODO: add {APPLICATION <appname>}
  /* Delay */
  NSString *delayPattern = [[NSString alloc] initWithFormat:@"\\{(%@|%@|)[ |=]+([0-9])+\\}",
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
    [self appendAppropriatePasteCommandForEntry:entry withContent:commandString toCommands:commands];
  }
}

+ (BOOL)updateModifierMask:(CGEventFlags *)mask forCommand:(NSString *)commandString {
  NSAssert(mask != NULL, @"Input pointer missing!");
  if(mask == NULL) {
    return NO;
  }
  NSNumber *flagNumber = [self modifierCommands][commandString.uppercaseString];
  if(!flagNumber) {
    return NO; // No modifier key, just leave
  }
  CGEventFlags flags = [flagNumber eventFlagsValue];
  *mask |= flags;
  return YES;
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
  CGKeyCode keyCode = [MPKeyMapper keyCodeForCharacter:@"V"];
  if(keyCode == kMPUnknownKeyCode) {
    return; // We did not find a mapping for "V"
  }
  [self sendPressKey:keyCode modifierFlags:kCGEventFlagMaskCommand];
}

- (void)execute {
  NSAssert(NO, @"Not Implemented");
}

- (BOOL)isValid {
  return NO; // No valid command
}
@end
