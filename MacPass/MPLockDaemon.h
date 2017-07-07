//
//  MPLockDaemon.h
//  MacPass
//
//  Created by Michael Starke on 16.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPLockDaemon : NSObject

+ (instancetype)defaultDaemon;
+ (instancetype)init NS_UNAVAILABLE;

@end
