//
//  MPPathControl.m
//  MacPass
//
//  Created by Michael Starke on 02.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPathControl.h"

@implementation MPPathControl

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      [[self cell] setShowsStateBy:NSNoCellMask];
    }
    return self;
}

@end
