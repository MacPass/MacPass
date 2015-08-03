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

@property (copy, readonly) KPKNode *node;
@property (weak, readonly) KPKNode *source;

- (instancetype)initWithSource:(KPKNode *)node;

- (BOOL)hasChanges;

@end
