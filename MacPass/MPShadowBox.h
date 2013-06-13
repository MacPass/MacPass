//
//  MPShadowBox.h
//  MacPass
//
//  Created by Michael Starke on 07.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_OPTIONS(NSUInteger, MPShadowDisplay) {
  MPShadowTop           = (1<<0),
  MPShadowBottom        = (1<<1),
  MPShadowTopAndBottom  = MPShadowTop | MPShadowBottom
};

@interface MPShadowBox : NSView

@property (assign, nonatomic) MPShadowDisplay shadowDisplay;

@end
