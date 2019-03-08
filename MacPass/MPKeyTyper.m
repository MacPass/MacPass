//
//  MPKeyboardTyper.m
//  MacPass
//
//  Created by Michael Starke on 30.10.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPKeyTyper.h"
#import "MPKeyMapper.h"
#import "MPAutotypeDaemon.h"

@implementation MPKeyTyper

+ (void)sendKey:(MPModifiedKey)key {
  [self _sendKey:key text:nil];
}

+ (void)sendText:(NSString *)text {
  [self _sendKey:MPMakeModifiedKey(0, 0) text:text];
}

+ (void)_sendKey:(MPModifiedKey)key text:(NSString *)text {
  if(key.modifier) {
    NSAssert(text.length == 0, @"Unable to send keyboard events with modifers and text.");
  }
  if(key.keyCode == 0 && key.modifier == 0 && text.length == 0) {
    return;
  }
  CGEventSourceRef eventSource = CGEventSourceCreate(kCGEventSourceStatePrivate);
  if(NULL == eventSource) {
    return; // We could not create our own source, abort!
  }
  CGEventRef pressKey = CGEventCreateKeyboardEvent (eventSource, key.keyCode, YES);
  CGEventRef releaseKey = CGEventCreateKeyboardEvent (eventSource, key.keyCode, NO);
  
  /*
   Set the modifiers to the ones we want
   We use our private event source so no modifier reset should be needed
   */
  CGEventSetFlags(pressKey, key.modifier);
  CGEventSetFlags(releaseKey, key.modifier);
  
  unichar *charBuffer = 0;
  if(text.length > 0) {
    charBuffer = malloc(sizeof(unichar) * text.length);
    [text getCharacters:charBuffer range:NSMakeRange(0, text.length)];
    CGEventKeyboardSetUnicodeString(pressKey, text.length, charBuffer);
    CGEventKeyboardSetUnicodeString(releaseKey, text.length, charBuffer);
  }
  
  /* Send the event */
  CGEventPost(kCGHIDEventTap, pressKey);
  /* TODO: Evaluate postToPid */
  //usleep(0.025 * NSEC_PER_MSEC);
  CGEventPost(kCGHIDEventTap, releaseKey);
  
  CFRelease(pressKey);
  CFRelease(releaseKey);
  CFRelease(eventSource);
  
  free(charBuffer);
}

+ (void)sendPaste {
  MPModifiedKey mKey = [MPKeyMapper modifiedKeyForCharacter:@"v"];
  if(mKey.keyCode == kMPUnknownKeyCode) {
    NSLog(@"Autotype error. Unable to map V to virtual key to send paste command. Skipping.");
    return; // We did not find a mapping for "V"
  }
  [self sendKey:MPMakeModifiedKey(kCGEventFlagMaskCommand, mKey.keyCode)];
}

@end
