//
//  MPAutotypeDaemon.m
//  MacPass
//
//  Created by Michael Starke on 15.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeDaemon.h"


static CGEventRef eventCallback(CGEventTapProxy proxy,
                                CGEventType type,
                                CGEventRef event,
                                void *userInfo) {
  
  MPAutotypeDaemon *daemon = (__bridge MPAutotypeDaemon *)userInfo;
  [daemon processEvent];
  CGEventFlags flags = CGEventGetFlags(event);
  // Update this to use settings?
  // Call into deamon via self pointer?
  if(flags & kCGEventFlagMaskCommand && flags) {
    NSLog(@"CMD +");
  }
  return event;
}

@interface MPAutotypeDaemon () {
  CFMachPortRef _portRef;
}

@end


@implementation MPAutotypeDaemon

- (id)init {
  self = [super init];
  if(self) {
    _portRef = CGEventTapCreate(kCGHIDEventTap,
                                kCGTailAppendEventTap,
                                kCGEventTapOptionListenOnly,
                                CGEventMaskBit(kCGEventKeyDown),
                                &eventCallback,
                                (__bridge void*)self);
    CFRunLoopSourceRef source = CFMachPortCreateRunLoopSource(CFAllocatorGetDefault(), _portRef, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopCommonModes);
    CFRelease(source);
  }
  return self;
}

- (void)dealloc {
  if(_portRef != NULL) {
    CFRelease(_portRef);
  }
}

- (void)processEvent {
  /* TODO */
}

- (void)sendKeystrokes {
  /* TODO */
  CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
  
  CGEventRef keyDown = CGEventCreateKeyboardEvent(source, 0x12, TRUE);
  CGEventSetFlags(keyDown, 0);
  CGEventRef keyUp = CGEventCreateKeyboardEvent(source, 0x12, FALSE);
  CGEventSetFlags(keyUp, 0);
  CGEventPost(kCGAnnotatedSessionEventTap, keyDown);
  CGEventPost(kCGAnnotatedSessionEventTap, keyUp);
  
  CFRelease(keyUp);
  CFRelease(keyDown);
  CFRelease(source);
}

@end
