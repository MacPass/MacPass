//
//  MPPluginHost.h
//  MacPass
//
//  Created by Michael Starke on 13/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KPKNode;
@class KPKEntry;
@class KPKGroup;

typedef BOOL (^NodeMatchBlock)(KPKNode *aNode);

@interface MPPluginHost : NSObject

+ (instancetype)sharedHost;

- (instancetype)init NS_UNAVAILABLE;

- (NSArray<KPKEntry *> *)filteredEntriesUsingBlock:(NodeMatchBlock)matchBlock;
- (NSArray<KPKGroup *> *)filteredGroupsUsingBlock:(NodeMatchBlock)matchBlock;

@end
