//
//  MPTableView.m
//  MacPass
//
//  Created by Michael Starke on 07.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPTableView.h"
#import "MPNotifications.h"

@interface MPTableView () {
  BOOL _didBecomeFirstResponder;
}

@end

@implementation MPTableView

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

- (void)drawBackgroundInClipRect:(NSRect)clipRect {
  /*
   We need to clear the outer areas
   as calling super will not do that for us
   */
  [[self backgroundColor] set];
  NSRectFill(clipRect);
  [super drawBackgroundInClipRect:clipRect];
}
@end
