//
//  MPPathBar.h
//  MacPass
//
//  Created by michael starke on 22.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPGradientView.h"

@class MPPathBar;
/*
 Delegate protocoll
 */
@protocol MPPathBarDelegateProtocoll <NSObject>

@required
- (NSUInteger)numberOfItemsInPathBar:(MPPathBar *)pathBar;
- (NSString *)pathbar:(MPPathBar *)pathbar stringAtIndex:(NSUInteger)index;

@optional
- (NSImage *)pathbar:(MPPathBar *)pathbar imageAtIndex:(NSUInteger)index;

@end


@interface MPPathBar : MPGradientView

@property (assign, nonatomic) id<MPPathBarDelegateProtocoll> delegate;

@end

