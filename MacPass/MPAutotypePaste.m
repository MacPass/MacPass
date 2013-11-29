//
//  MPAutotypePaste.m
//  MacPass
//
//  Created by Michael Starke on 24/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypePaste.h"
#import "MPPasteBoardController.h"

#import "NSString+Placeholder.h"

@implementation MPAutotypePaste

/**
 *  Simple copy paste action
 */
- (void)executeWithEntry:(KPKEntry *)entry {
  if([self.commandString length] > 0) {
    MPPasteBoardController *controller = [MPPasteBoardController defaultController];
    if([self.commandString isPlaceholder]) {
      BOOL didReplace;
      NSString *evaluatedPlaceholder = [self.commandString evaluatePlaceholderWithEntry:entry didReplace:&didReplace];
      [controller copyObjects:@[evaluatedPlaceholder]];
    }
    else {
      [controller copyObjects:@[self.commandString]];
    }
    /* Find the correct key code! */
    [self sendPasteKeyCode];
  }
}

@end
