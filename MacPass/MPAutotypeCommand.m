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

#import "MPAutotypeContext.h"
#import "MPKeyMapper.h"

#import "KPKAutotypeCommands.h"

#import "NSString+Commands.h"

#import <Carbon/Carbon.h>

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
 *  @note KeypassControl is mapped to command!
 *
 *  @return dictionary with commands as keys and CGEventFlags as wrapped values
 */
+ (NSDictionary *)modifierCommands {
  static NSDictionary *modifierCommands;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    modifierCommands = @{
                         kKPKAutotypeAlt : @(kCGEventFlagMaskAlternate),
                         kKPKAutotypeControl : @(kCGEventFlagMaskCommand),
                         kKPKAutotypeShift : @(kCGEventFlagMaskShift)
                         };
  });
  return modifierCommands;
}

+ (NSArray *)commandsForContext:(MPAutotypeContext *)context {
  if(![context isValid]) {
    return nil;
  }
  NSUInteger reserverd = [context.normalizedCommand length] / 4;
  NSMutableArray *commands = [[NSMutableArray alloc] initWithCapacity:reserverd];
  NSMutableArray __block *commandRanges = [[NSMutableArray alloc] initWithCapacity:reserverd];
  NSRegularExpression *commandRegExp = [[NSRegularExpression alloc] initWithPattern:@"\\{[^\\}]+\\}" options:NSRegularExpressionCaseInsensitive error:0];
  NSAssert(commandRegExp, @"RegExp is constant. Has to work all the time");
  [commandRegExp enumerateMatchesInString:context.normalizedCommand options:0 range:NSMakeRange(0, [context.normalizedCommand length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
    @autoreleasepool {
      [commandRanges addObject:[NSValue valueWithRange:result.range]];
    }
  }];
  NSUInteger lastLocation = 0;
  MPAutotypeKeyPress *keyPress;
  for(NSValue *rangeValue in commandRanges) {
    NSRange commandRange = [rangeValue rangeValue];
    /* All non-commands will get translated into paste commands */
    if(commandRange.location > lastLocation) {
      /* If were modifiers we need to use the next single stroke and make update the modifier command */
      if(keyPress) {
      }
      NSString *pasteValue = [context.normalizedCommand substringWithRange:NSMakeRange(lastLocation, commandRange.location - lastLocation)];
      // Determin if it's amodifier key, and collect them!
      [self appendPasteCommandForContent:pasteValue toCommands:commands];
    }
    NSString *commandString = [context.normalizedCommand substringWithRange:commandRange];
    [self appendCommandForString:commandString toCommands:commands];
    lastLocation = commandRange.location;
  }
  return commands;
}

+ (void)appendPasteCommandForContent:(NSString *)pasteContent toCommands:(NSMutableArray *)commands {
  if(pasteContent) {
    MPAutotypePaste *pasteCommand = [[MPAutotypePaste alloc] initWithString:pasteContent];
    [commands addObject:pasteCommand];
  }
}

+ (void)appendCommandForString:(NSString *)commandString toCommands:(NSMutableArray *)commands {
  MPAutotypeCommand *
  if(!commandString) {
    NSDictionary *modifier = [self modifierCommands];
  }
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
