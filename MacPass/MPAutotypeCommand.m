//
//  MPAutotypeCommand.m
//  MacPass
//
//  Created by Michael Starke on 10/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeCommand.h"

#import "MPAutotypeContext.h"
#import "MPKeyMapper.h"

#import "NSString+Commands.h"

#import <Carbon/Carbon.h>

@implementation MPAutotypeCommand

+ (NSArray *)commandsForContext:(MPAutotypeContext *)context {
  if([context isValid]) {
    return nil;
  }
  BOOL outsideCommand = YES;
  NSInteger currentIndex;
  while(YES) {
    if(outsideCommand) {
      NSRange openingBracketRange = [context.normalizedCommand rangeOfString:@"{"];
      if(openingBracketRange.location != NSNotFound && openingBracketRange.length == 1) {
      }
    }
    else {
    }
    
  }
  return nil;
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
