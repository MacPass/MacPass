//
//  MPOutlineViewController.h
//  MacPass
//
//  Created by michael starke on 19.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

@interface MPOutlineViewController : MPViewController

@property (retain, readonly) NSMenu *menu;
- (void)deselectAll;

@end
