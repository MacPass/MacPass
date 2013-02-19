//
//  MPMainWindowController.h
//  MacPass
//
//  Created by Michael Starke on 24.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MPViewController;

@interface MPMainWindowController : NSWindowController

- (void)showEntries;
/*
 Sets the content View controller
 @param viewController - use nil to reset to welcome screen
 */
- (void)setContentViewController:(MPViewController *)viewController;

@end
