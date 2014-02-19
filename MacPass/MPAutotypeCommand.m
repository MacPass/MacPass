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
  if([context isValid]) {
    return nil;
  }
  NSMutableArray *commands = [[NSMutableArray alloc] initWithCapacity:10];
  BOOL outsideCommand = YES;
  NSString *unparsedCommand = context.normalizedCommand;
  while(YES) {
    /* Outside Command */
    if(outsideCommand) {
      NSRange openingBracketRange = [unparsedCommand rangeOfString:@"{"];
      if(openingBracketRange.location != NSNotFound && openingBracketRange.length == 1) {
        outsideCommand = NO;
        NSString *skipped = [unparsedCommand substringToIndex:openingBracketRange.location];
        unparsedCommand = [unparsedCommand substringFromIndex:openingBracketRange.location + 1];
      }
      else {
        /* No more opeing brackets, stop - or none at all */
        [self appendPasteCommandForContent:unparsedCommand toCommands:commands];
        break;
      }
    }
    /* Inside Command */
    else {
      NSRange closingBracketRange = [unparsedCommand rangeOfString:@"}"];
      if(closingBracketRange.location == NSNotFound || closingBracketRange.length != 1) {
        return nil;
      }
      outsideCommand = NO;
    }
  }
  return commands;
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
