//
//  MPOutlineView.m
//  MacPass
//
//  Created by Michael Starke on 23.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineView.h"
#import "MPNotifications.h"

@interface MPOutlineView () {
  BOOL _didBecomeFirstResponder;
}

@end

@implementation MPOutlineView

- (void)mouseDown:(NSEvent *)theEvent {
  [super mouseDown:theEvent];
  if(_didBecomeFirstResponder) {
    [[NSNotificationCenter defaultCenter] postNotificationName:MPDidActivateViewNotification
                                                        object:self
                                                      userInfo:nil];
  }
  _didBecomeFirstResponder = NO;
}

- (BOOL)becomeFirstResponder {
  _didBecomeFirstResponder = YES;
  return YES;
}

@end
