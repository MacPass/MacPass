//
//  MPGradientView.h
//  MacPass
//
//  Created by Michael Starke on 20.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
 A view just displaying a gradient
 */
@interface MPGradientView : NSView

- (id)initWithFrame:(NSRect)frame activeGradient:(NSGradient *)activeGradient inactiveGradient:(NSGradient *)inactiveGradient;

@end
