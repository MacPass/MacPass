//
//  MPPathBarItemView.h
//  MacPass
//
//  Created by michael starke on 22.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPPathBarItemView : NSView

@property (retain, nonatomic) NSImage *image;
@property (retain, nonatomic) NSString *text;

- (void)sizeToFit;

@end
