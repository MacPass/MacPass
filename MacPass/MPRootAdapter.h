//
//  MPRootAdapter.h
//  MacPass
//
//  Created by Michael Starke on 26.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KdbTree;

@interface MPRootAdapter : NSObject

@property (readonly, strong) NSArray *groups;
@property (nonatomic, strong) KdbTree *tree;
/* Subs to support interface */
@property (weak, readonly, nonatomic) NSArray *entries;

@end
