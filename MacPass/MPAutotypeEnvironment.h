//
//  MPAutotypeEnvironment.h
//  MacPass
//
//  Created by Michael Starke on 15.01.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class KPKEntry;
@class MPAutotypeContext;

@interface MPAutotypeEnvironment : NSObject

@property (readonly, weak) KPKEntry *entry;
@property (readonly) pid_t pid;
@property (readonly, copy) NSString *windowTitle;
@property (readonly) BOOL hidden;
@property (readonly) BOOL isSelfTargeting;

+ (instancetype)environmentWithTargetApplication:(NSRunningApplication *)targetApplication entry:(KPKEntry * _Nullable)entry;
- (instancetype)initWithTargetApplication:(NSRunningApplication *)targetApplication entry:(KPKEntry * _Nullable)entry NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
