//
//  MPPluginManager.h
//  MacPass
//
//  Created by Michael Starke on 16/07/15.
//  Copyright (c) 2015 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KPKNode;

@interface MPPluginManager : NSObject

typedef BOOL (^NodeMatchBlock)(KPKNode *aNode);

+ (instancetype)sharedManager;

- (NSArray *)filteredEntriesUsingBlock:(NodeMatchBlock) matchBlock;
- (NSArray *)filteredGroupsUsingBlock:(NodeMatchBlock) matchBlock;

@end
