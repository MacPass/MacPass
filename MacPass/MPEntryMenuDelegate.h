//
//  MPEntryMenuDelegate.h
//  MacPass
//
//  Created by Michael Starke on 17.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MPEntryViewController;

@interface MPEntryMenuDelegate : NSObject <NSMenuDelegate>

@property (weak) MPEntryViewController *viewController;

@end
