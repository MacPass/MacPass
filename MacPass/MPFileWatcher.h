//
//  MPFileWatcher.h
//  MacPass
//
//  Created by Michael Starke on 17/12/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPFileWatcher;
typedef void (^MPFileWatcherBlock)(void);
/* TODO: Cocoanetics DTFileMonitor */
@interface MPFileWatcher : NSObject

@property (copy, readonly) NSURL *URL;

+ (instancetype)fileWatcherWithURL:(NSURL *)url changeBlock:(MPFileWatcherBlock)block;

- (instancetype)initWithURL:(NSURL *)url changeBlock:(MPFileWatcherBlock)block;

- (void)startMonitoring;
- (void)stopMonitoring;

@end
