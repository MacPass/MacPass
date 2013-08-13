//
//  MPSegmentedToolbarButton.h
//  MacPass
//
//  Created by Michael Starke on 26.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPContextToolbarButton : NSSegmentedControl

- (void)setImage:(NSImage *)image;
- (void)setContextMenu:(NSMenu *)menu;

@end
