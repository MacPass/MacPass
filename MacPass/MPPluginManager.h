//
//  MPPluginManager.h
//  MacPass
//
//  Created by Michael Starke on 16/07/15.
//  Copyright (c) 2015 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KPKNode;
@class MPPlugin;

@interface MPPluginManager : NSObject

@property (readonly, copy) NSArray <MPPlugin __kindof*> *plugins;

typedef BOOL (^NodeMatchBlock)(KPKNode *aNode);

+ (instancetype)sharedManager;

- (instancetype)init NS_UNAVAILABLE;

- (NSArray *)filteredEntriesUsingBlock:(NodeMatchBlock) matchBlock;
- (NSArray *)filteredGroupsUsingBlock:(NodeMatchBlock) matchBlock;

- (void)loadPlugins;
- (void)installPluginAtURL:(NSURL *)url;

@end
