//
//  MPButtonBarButton.m
//  MacPass
//
//  Created by Michael Starke on 01.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPButtonBarButton.h"

@implementation MPButtonBarButton

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setButtonType:NSPushOnPushOffButton];
    [self setBordered:NO];
    
    [[self cell] setHighlightsBy:NSContentsCellMask];
    [[self cell] setShowsStateBy:NSNoCellMask];
    [[self cell] setBackgroundStyle:NSBackgroundStyleRaised];
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  if(self.state == NSOnState) {
    NSRect drawingRect = [self bounds];
    NSColor *edgeColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.2];
    NSColor *middelColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0];
    NSGradient *borderGradient = [[NSGradient alloc] initWithColors:@[edgeColor, middelColor]];
    drawingRect.size.width = 5;
    [borderGradient drawInRect:drawingRect relativeCenterPosition:NSMakePoint(-1.0, 0)];
    drawingRect.origin.x = [self bounds].size.width - 5;
    [borderGradient drawInRect:drawingRect relativeCenterPosition:NSMakePoint(1.0, 0)];
  }
  [super drawRect:dirtyRect];
}

@end
