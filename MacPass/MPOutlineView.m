//
//  MPOutlineView.m
//  MacPass
//
//  Created by Michael Starke on 23.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineView.h"
#import "MPNotifications.h"

@implementation MPOutlineView

- (BOOL)becomeFirstResponder {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDidBecomeFirstResonderNotification
                                                      object:self
                                                    userInfo:nil];
  return YES;
}

@end
