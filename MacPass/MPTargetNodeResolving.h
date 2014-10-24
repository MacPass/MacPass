//
//  MPTargetItemResolving.h
//  MacPass
//
//  Created by Michael Starke on 21/10/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KPKEntry;
@class KPKGroup;
@class KPKNode;

@protocol MPTargetNodeResolving <NSObject>

@optional
- (KPKNode *)currentTargetNode;
- (KPKGroup *)currentTargetGroup;
- (KPKEntry *)currentTargetEntry;

@end
