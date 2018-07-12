//
//  MPUserNotificationCenterDelegate.m
//  MacPass
//
//  Created by Michael Starke on 05.12.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPUserNotificationCenterDelegate.h"

NSString *const kMPUserNotificationInfoKeyNotificationType = @"kMPUserNotificationInfoKeyNotificationType";
NSString *const kMPUserNotificationTypeAutotype = @"kMPUserNotificationTypeAutotype";

@implementation MPUserNotificationCenterDelegate

- (instancetype)init {
  self = [super init];
  if(self) {
    NSUserNotificationCenter.defaultUserNotificationCenter.delegate = self;
  }
  return self;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
  NSLog(@"%@", notification);
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  if(!userInfo) {
    return NO;
  }
  NSString *value = userInfo[kMPUserNotificationInfoKeyNotificationType];
  return [value isEqualToString:kMPUserNotificationTypeAutotype];
}


@end
