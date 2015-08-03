//
//  MPEditSession.h
//  MacPass
//
//  Created by Michael Starke on 30/05/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KPKNode;

@interface MPEditingSession : NSObject

@property (strong, readonly) KPKNode *node;
@property (copy, readonly) KPKNode *rollbackNode;

- (instancetype)initWithNode:(KPKNode *)node;

- (BOOL)hasChanges;

@end
