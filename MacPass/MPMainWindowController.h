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
- (void)showMainWindow:(id)sender;
- (void)performFindPanelAction:(id)sender;
- (void)clearOutlineSelection:(id)sender;

@end
