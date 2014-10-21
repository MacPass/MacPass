//
//  MPTargetItemResolving.h
//  MacPass
//
//  Created by Michael Starke on 21/10/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KPKNode;

@protocol MPTargetItemResolving <NSObject>

@required
- (KPKNode *)targetItemForAction;

@end
