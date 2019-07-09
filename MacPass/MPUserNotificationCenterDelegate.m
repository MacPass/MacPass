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
#import "MPAutotypeDoctor.h"

NSString *const MPUserNotificationTypeKey = @"MPUserNotificationTypeKey";
NSString *const MPUserNotificationTypeAutotypeFeedback = @"MPUserNotificationTypeAutotypeFeedback";
NSString *const MPUserNotificationTypeAutotypeOpenDocumentRequest = @"MPUserNotificationTypeAutotypeOpenDocumentRequest";
NSString *const MPUserNotificationTypeRunAutotypeDoctor = @"MPUserNotificationTypeRunAutotypeDoctor";

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
  NSString *notificationType = userInfo[MPUserNotificationTypeKey];
  if([notificationType isEqualToString:MPUserNotificationTypeAutotypeOpenDocumentRequest]) {
    [((MPDocumentController*)NSDocumentController.sharedDocumentController) reopenLastDocument];
  }
  else if([notificationType isEqualToString:MPUserNotificationTypeRunAutotypeDoctor]) {
    [MPAutotypeDoctor.defaultDoctor runChecksAndPresentResults];
  }
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
  NSString *notificationType = notification.userInfo[MPUserNotificationTypeKey];
  if([notificationType isEqualToString:MPUserNotificationTypeAutotypeFeedback]) {
    return YES;
  }
  if([notificationType isEqualToString:MPUserNotificationTypeRunAutotypeDoctor]) {
    return YES;
  }
  return NO;
}


@end
