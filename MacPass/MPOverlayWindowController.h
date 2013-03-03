//
//  MPOverlayWindowController.h
//  MacPass
//
//  Created by Michael Starke on 03.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPOverlayWindowController : NSWindowController

+ (MPOverlayWindowController *)sharedController;

/*
 Displays an overlay centered at the given view. The Windows is added as a childwindow to the view window
 */
- (void)displayOverlayImage:(NSImage *)imageOrNil label:(NSString *)labelOrNil atView:(NSView *)view;

@end
