//
//  MPAutotypePaste.m
//  MacPass
//
//  Created by Michael Starke on 24/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypePaste.h"
#import "MPPasteBoardController.h"

#import <Carbon/Carbon.h>

@implementation MPAutotypePaste

/**
 *  Simple copy paste action
 */
- (void)execute {
  if([self.commandString length] > 0) {
    MPPasteBoardController *controller = [MPPasteBoardController defaultController];
    [controller copyObjects:@[self.commandString]];
    [self sendPressKey:kVK_ANSI_V modifierFlags:kCGEventFlagMaskCommand];
  }
}

@end
