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

/**
 *  Displays an overlay HUD style image with the given text, image centerd at the given view.
 *  There are two use cases. Either displaying information over a view by providing on,
 *  or displaying information on the main screen by using nil for the view.
 *
 *  @param imageOrNil Image to be displayed. If nil, no image will be shown.
 *  @param labelOrNil Text to be displayed. If nil, no text will be rendered
 *  @param viewOrNil  View to center the Overlay in. If nil, the window will be center and displayed on the main screen
 */
- (void)displayOverlayImage:(NSImage *)imageOrNil label:(NSString *)labelOrNil atView:(NSView *)viewOrNil;

@end
