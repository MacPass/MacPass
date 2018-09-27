//
//  MPUserNotificationCenterDelegate.m
//  MacPass
//
//  Created by Michael Starke on 05.12.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "MPUserNotificationCenterDelegate.h"
#import "MPDocumentController.h"

NSString *const MPUserNotificationTypeKey = @"MPUserNotificationTypeKey";
NSString *const MPUserNotificationTypeAutotypeFeedback = @"MPUserNotificationTypeAutotypeFeedback";
NSString *const MPUserNotificationTypeAutotypeOpenDocumentRequest = @"MPUserNotificationTypeAutotypeOpenDocumentRequest";

@implementation MPUserNotificationCenterDelegate

- (instancetype)init {
  self = [super init];
  if(self) {
    NSUserNotificationCenter.defaultUserNotificationCenter.delegate = self;
  }
  return self;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  if([userInfo[MPUserNotificationTypeKey] isEqualToString:MPUserNotificationTypeAutotypeOpenDocumentRequest]) {
    [((MPDocumentController*)NSDocumentController.sharedDocumentController) reopenLastDocument];
  }
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
  return [notification.userInfo[MPUserNotificationTypeKey] isEqualToString:MPUserNotificationTypeAutotypeFeedback];
}


@end
