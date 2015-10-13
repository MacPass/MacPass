//
//  MPEditSession.h
//  MacPass
//
//  Created by Michael Starke on 30/05/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class KPKNode;

@interface MPEditingSession : NSObject

@property (copy, readonly) KPKNode *node;
@property (nullable, weak, readonly) KPKNode *source;

+ (instancetype)editingSessionWithSource:(KPKNode *)node;
- (instancetype)initWithSource:(KPKNode *)node;

- (instancetype)init NS_UNAVAILABLE;

- (BOOL)hasChanges;

@end

NS_ASSUME_NONNULL_END

