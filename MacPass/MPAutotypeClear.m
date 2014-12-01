//
//  MPAutotypeClear.m
//  MacPass
//
//  Created by Michael Starke on 20/08/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeClear.h"
#import "MPKeyMapper.h"
#import <Carbon/Carbon.h>

@implementation MPAutotypeClear

- (NSString *)description {
  return [[self class] description];
}

- (void)execute {
  CGKeyCode keyCode = [MPKeyMapper keyCodeForCharacter:@"A"];
  if(keyCode == kMPUnknownKeyCode) {
    NSLog(@"Unable to generate key code for 'A'");
    return;
  }
  [self sendPressKey:keyCode modifierFlags:kCGEventFlagMaskCommand];
  [self sendPressKey:kVK_Delete modifierFlags:0];
}

@end
