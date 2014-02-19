//
//  MPAutotypeCommand.m
//  MacPass
//
//  Created by Michael Starke on 10/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeCommand.h"

#import "MPAutotypePaste.h"

#import "MPAutotypeContext.h"
#import "MPKeyMapper.h"

#import "NSString+Commands.h"

#import <Carbon/Carbon.h>

@implementation MPAutotypeCommand

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
  NSUInteger skipped = 0;
  for(NSValue *rangeValue in commandRanges) {
    NSRange range = [rangeValue rangeValue];
    /* All non-commands will get translated into paste commands */
    if(range.location > skipped) {
      NSString *pasteValue = [context.normalizedCommand substringWithRange:NSMakeRange(skipped, range.location - skipped)];
      [self appendPasteCommandForContent:pasteValue toCommands:commands];
      skipped = range.location;
    }
  }
  return nil;
}

+ (MPAutotypeCommand *)appendPasteCommandForContent:(NSString *)pasteContent toCommands:(NSMutableArray *)commands {
  if(pasteContent) {
    MPAutotypePaste *pasteCommand = [[MPAutotypePaste alloc] initWithString:pasteContent];
    [commands addObject:pasteCommand];
  }
}

+ (MPAutotypeCommand *)appendCommandForString:(NSString *)commandString toCommands:(NSMutableArray *)commands {
  if(commandString) {
    /* Find appropriate command */
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
