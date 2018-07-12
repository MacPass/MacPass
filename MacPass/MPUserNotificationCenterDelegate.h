//
//  MPUserNotificationCenterDelegate.h
//  MacPass
//
//  Created by Michael Starke on 05.12.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *const kMPUserNotificationInfoKeyNotificationType;
FOUNDATION_EXTERN NSString *const kMPUserNotificationTypeAutotype;

@interface MPUserNotificationCenterDelegate : NSObject <NSUserNotificationCenterDelegate>

@end
