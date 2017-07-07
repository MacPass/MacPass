//
//  MPPluginHost.h
//  MacPass
//
//  Created by Michael Starke on 16/07/15.
//  Copyright (c) 2015 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const MPPluginHostWillLoadPlugin;
FOUNDATION_EXPORT NSString *const MPPluginHostDidLoadPlugin;

FOUNDATION_EXPORT NSString *const MPPluginHostPluginBundleIdentifiyerKey;

@class MPPlugin;

@interface MPPluginHost : NSObject

@property (readonly, copy) NSArray <MPPlugin __kindof*> *plugins;
@property (nonatomic, readonly) BOOL loadUnsecurePlugins;

+ (instancetype)sharedHost;

- (instancetype)init NS_UNAVAILABLE;

@end
