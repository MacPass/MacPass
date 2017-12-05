//
//  MPUserNotificationCenterDelegate.m
//  MacPass
//
//  Created by Michael Starke on 05.12.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPUserNotificationCenterDelegate.h"

@implementation MPUserNotificationCenterDelegate

- (instancetype)init {
  self = [super init];
  if(self) {
    NSUserNotificationCenter.defaultUserNotificationCenter.delegate = self;
  }
  return self;
}

@end
