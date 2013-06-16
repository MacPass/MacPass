//
//  MPLockDaemon.h
//  MacPass
//
//  Created by Michael Starke on 16.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

APPKIT_EXTERN NSString *const MPShouldLockDatabaseNotification;

@interface MPLockDaemon : NSObject

+ (MPLockDaemon *)sharedInstance;

@end
