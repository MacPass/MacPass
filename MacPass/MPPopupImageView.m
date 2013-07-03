//
//  MPPopupImageView.m
//  MacPass
//
//  Created by Michael Starke on 10.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPopupImageView.h"

#define MPTRIANGLE_HEIGHT 8
#define MPTRIANGLE_WIDTH 10
#define MPTRIANGLE_OFFSET 2

@interface MPPopupImageView ()

@property (assign) BOOL showOverlay;

- (void)_setupView;

@end

@implementation MPPopupImageView

- (id)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if(self) {
    [self _setupView];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if(self) {
    [self _setupView];
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  
  if(self.showOverlay && [self isEnabled]) {
    [[NSGraphicsContext currentContext] saveGraphicsState];

    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:4 yRadius:4];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowBlurRadius:6];
    [shadow setShadowOffset:NSMakeSize(0, 0)];
    [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.2 alpha:1]];
    [shadow set];

    [path addClip];
    [[NSColor colorWithCalibratedWhite:1 alpha:0.2] setFill];
    [path fill];
    NSBezierPath *strokePath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect([self bounds], -3, -3) xRadius:4 yRadius:4];
    [strokePath setLineWidth:6];
    [strokePath stroke];
//    [shadow setShadowBlurRadius:2];
//    [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0 alpha:0.5]];
//    [shadow setShadowOffset:NSMakeSize(0, -1)];
//    [shadow set];
//    
//    NSBezierPath *triangle = [NSBezierPath bezierPath];
//    NSPoint left = NSMakePoint([self bounds].size.width - MPTRIANGLE_OFFSET - MPTRIANGLE_WIDTH, MPTRIANGLE_OFFSET + MPTRIANGLE_HEIGHT);
//    NSPoint right = NSMakePoint(left.x + MPTRIANGLE_WIDTH, left.y);
//    NSPoint bottom = NSMakePoint(left.x + 0.5 * MPTRIANGLE_WIDTH, MPTRIANGLE_OFFSET);
//  
//    [triangle moveToPoint:left];
//    [triangle lineToPoint:right];
//    [triangle lineToPoint:bottom];
//    [triangle closePath];
//    
//    [[NSColor whiteColor] set];
//    [triangle fill];
    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
  }
  [super drawRect:dirtyRect];
  /* Draw Overlay */
}

- (void)mouseEntered:(NSEvent *)theEvent {
  self.showOverlay = YES;
  [self setNeedsDisplay:YES];
  [super mouseEntered:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent {
  self.showOverlay = NO;
  [self setNeedsDisplay:YES];
  [super mouseExited:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent {
  [self sendAction:[self action] to:[self target]];
}

- (void)_setupView {
  /* Add tracking area for mouse events */
  NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                              options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow)
                                                                owner:self
                                                             userInfo:nil];
  [self addTrackingArea:trackingArea];
}

@end
