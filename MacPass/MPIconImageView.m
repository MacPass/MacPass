//
//  MPPopupImageView.m
//  MacPass
//
//  Created by Michael Starke on 10.03.13.
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

#import "MPIconImageView.h"
#import "MPModelChangeObserving.h"
#import "MPDocument.h"

#define MPTRIANGLE_HEIGHT 8
#define MPTRIANGLE_WIDTH 10
#define MPTRIANGLE_OFFSET 2

@interface MPIconImageView ()

@property (assign) BOOL showOverlay;

- (void)_setupView;

@end

@implementation MPIconImageView

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

- (void)drawRect:(NSRect)dirtyRect {
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
  [self registerForDraggedTypes:@[(NSString *)kUTTypeURL, (NSString *)kUTTypeFileURL]];
  /* Add tracking area for mouse events */
  NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                              options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow)
                                                                owner:self
                                                             userInfo:nil];
  [self addTrackingArea:trackingArea];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
  return NSDragOperationCopy;
}

- (void)setImage:(NSImage *)image {
  /*
    setImage is only called via drag'n'drop. We are bound so we ignore this.
   */
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
  NSPasteboard *pBoard = [sender draggingPasteboard];
  NSArray *urls = [pBoard readObjectsForClasses:@[NSURL.class] options:@{ NSPasteboardURLReadingFileURLsOnlyKey : @YES }];
  if(urls.count != 1) {
    return NO;
  }
  
  KPKIcon *icon = [[KPKIcon alloc] initWithImageAtURL:urls.firstObject];
  if(icon.image) {
    MPDocument *document = [NSDocumentController sharedDocumentController].currentDocument;
    [document.tree.metaData addCustomIcon:icon];
  }
  [self.modelChangeObserver willChangeModelProperty];
  self.node.iconUUID = icon.uuid;
  [self.modelChangeObserver didChangeModelProperty];
  return YES;
}

@end
