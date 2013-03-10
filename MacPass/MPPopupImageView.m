//
//  MPPopupImageView.m
//  MacPass
//
//  Created by Michael Starke on 10.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPopupImageView.h"

@interface MPPopupImageView ()

@property (assign) BOOL showOverlay;
@property (retain) NSString *overlayText;
@property (retain) NSDictionary *fontAttributes;
@property (assign) NSSize textSize;

- (void)_setupView;
- (NSRect)_centeredFontRectangle;

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
  [super drawRect:dirtyRect];
  if(self.showOverlay) {
    [[NSGraphicsContext currentContext] saveGraphicsState];
    NSRect rect = NSInsetRect([self bounds], 2, 14);
    rect.origin.x = 2;
    rect.origin.y = 14;
    [[NSColor greenColor] set];
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowBlurRadius:2];
    [shadow setShadowOffset:NSMakeSize(0, -1)];
    [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0 alpha:0.5]];
    [shadow set];
    [[NSColor whiteColor] set];
    NSRectFill([self _centeredFontRectangle]);
    [self.overlayText drawInRect:[self _centeredFontRectangle] withAttributes:self.fontAttributes];
    [shadow release];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
  }
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

- (NSRect)_centeredFontRectangle {
  CGFloat leftMargin = floor( 0.5 * [self bounds].size.width - self.textSize.width );
  CGFloat bottomMargin = floor( 0.5 * [self bounds].size.height - self.textSize.height);
  return NSMakeRect(leftMargin, bottomMargin, self.textSize.width, self.textSize.height);
}

- (void)_setupView {
  /* Setup font for drawing an precalulate some things */
  _overlayText = [NSLocalizedString(@"CHANGE_IMAGE", @"Overlay text for popup image") retain];
  NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  paragraphStyle.alignment = NSCenterTextAlignment;
  _fontAttributes = [@{
                                   NSFontAttributeName :[NSFont boldSystemFontOfSize:11],
                                   NSForegroundColorAttributeName : [NSColor whiteColor],
                                   } retain];
  [paragraphStyle release];
  _textSize = [self.overlayText sizeWithAttributes:_fontAttributes];
  
  /* Add tracking area for mouse events */
  NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                              options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow)
                                                                owner:self
                                                             userInfo:nil];
  [self addTrackingArea:trackingArea];
  [trackingArea release];
}

@end
