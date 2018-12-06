//
//  MPAutotypeExectutionContext.h
//  MacPass
//
//  Created by Michael Starke on 06.12.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPAutotypeExecutionContext : NSObject

@property (readonly) pid_t targetPid;

- (instancetype)initWithTargetPid:(pid_t)pid NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
