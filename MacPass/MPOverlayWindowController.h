//
//  MPOverlayWindowController.h
//  MacPass
//
//  Created by Michael Starke on 03.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Cocoa/Cocoa.h>

@interface MPOverlayWindowController : NSWindowController

@property (nonatomic, strong, readonly, class) MPOverlayWindowController *sharedController;

/**
 *  Displays an overlay HUD style image with the given text, image centered at the given view.
 *  There are two use cases. Either displaying information over a view by providing on,
 *  or displaying information on the main screen by using nil for the view.
 *
 *  @param imageOrNil Image to be displayed. If nil, no image will be shown.
 *  @param labelOrNil Text to be displayed. If nil, no text will be rendered
 *  @param viewOrNil  View to center the Overlay in. If nil, the window will be center and displayed on the main screen
 */
- (void)displayOverlayImage:(NSImage *)imageOrNil label:(NSString *)labelOrNil atView:(NSView *)viewOrNil;

@end
