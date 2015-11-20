//
//  MPPluginHost.h
//  MacPass
//
//  Created by Michael Starke on 13/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KPKNode;

typedef BOOL (^NodeMatchBlock)(KPKNode *aNode);

@interface MPPluginHost : NSObject

+ (instancetype)sharedHost;

- (instancetype)init NS_UNAVAILABLE;

- (NSArray *)filteredEntriesUsingBlock:(NodeMatchBlock)matchBlock;
- (NSArray *)filteredGroupsUsingBlock:(NodeMatchBlock)matchBlock;

@end
