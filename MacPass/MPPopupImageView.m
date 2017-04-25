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
  
  if(self.showOverlay && self.enabled) {
    [[NSGraphicsContext currentContext] saveGraphicsState];

    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:4 yRadius:4];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 6;
    shadow.shadowOffset = NSMakeSize(0, 0);
    shadow.shadowColor =  [NSColor colorWithCalibratedWhite:0.2 alpha:1];
    [shadow set];

    [path addClip];
    [[NSColor colorWithCalibratedWhite:1 alpha:0.2] setFill];
    [path fill];
    NSBezierPath *strokePath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect([self bounds], -3, -3) xRadius:4 yRadius:4];
    strokePath.lineWidth = 6;
    [strokePath stroke];
    [NSGraphicsContext.currentContext restoreGraphicsState];
  }
  [super drawRect:dirtyRect];
}

- (void)mouseEntered:(NSEvent *)theEvent {
  self.showOverlay = YES;
  self.needsDisplay = YES;
  [super mouseEntered:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent {
  self.showOverlay = NO;
  self.needsDisplay = YES;
  [super mouseExited:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent {
  if(self.enabled) {
    [self sendAction:self.action to:self.target];
  }
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
