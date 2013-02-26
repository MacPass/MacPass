//
//  MPButton.h
//  MacPass
//
//  Created by michael starke on 26.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPToolbarButton : NSButton

/* This methods ensure, that the button get sized correctly if used as the view in a NSToolbarItem*/
- (void)setControlSize:(NSControlSize)controlSize;
- (NSControlSize)controlSize;


@end
