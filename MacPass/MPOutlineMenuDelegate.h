//
//  MPOutlineMenuDelegate.h
//  MacPass
//
//  Created by Michael Starke on 29.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPOutlineViewController;

@interface MPOutlineMenuDelegate : NSObject <NSMenuDelegate>

@property (weak) MPOutlineViewController *viewController;

@end
