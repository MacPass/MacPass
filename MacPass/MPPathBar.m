//
//  MPPathBar.m
//  MacPass
//
//  Created by michael starke on 22.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPPathBar.h"
#import "MPPathBarItemView.h"

#define INTER_BUTTON_SPACING 5.0

@interface MPPathBar ()

@property (retain) NSMutableArray *itemViews;
@property (assign) BOOL delegateSupportsImage;

- (void)update;
- (void)createViews;
- (MPPathBarItemView *)viewForIndex:(NSUInteger)index;

@end

@implementation MPPathBar

- (id)initWithFrame:(NSRect)frame activeGradient:(NSGradient *)activeGradient inactiveGradient:(NSGradient *)inactiveGradient {
  self = [super initWithFrame:frame activeGradient:activeGradient inactiveGradient:inactiveGradient];
  if(self) {
    _itemViews = [[NSMutableArray alloc] initWithCapacity:5];
    _delegateSupportsImage = NO;
    [self createViews];
  }
  return self;
}

- (void)dealloc {
  self.itemViews = nil;
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
  [self update];
}

- (void)createViews {
  NSUInteger items = 5;//[self.delegate numberOfItemsInPathBar:self];
  CGFloat startPosition = 0;
  for (NSUInteger iIndex = 0; iIndex < items; iIndex++) {
    MPPathBarItemView *textField = [self viewForIndex:iIndex];
    [textField setFrame:NSMakeRect(startPosition, 0, 20, 20)];
    [self addSubview:textField];
  }
  [self update];
}

- (void)update {
  CGFloat startPosition = 0;
  for(MPPathBarItemView *view in self.itemViews) {
    [view sizeToFit];
    NSRect newFrame = [view frame];
    newFrame.origin.x = startPosition;
    [view setFrame:newFrame];
    startPosition +=  newFrame.size.width + INTER_BUTTON_SPACING;
  }
}

- (void)setDelegate:(id<MPPathBarDelegateProtocoll>)delegate {
  if(_delegate != delegate) {
    _delegate = delegate;
    self.delegateSupportsImage = [_delegate respondsToSelector:@selector(pathbar:imageAtIndex:)];
    [self update];
  }
}


- (MPPathBarItemView *)viewForIndex:(NSUInteger)index {
  MPPathBarItemView *itemView = nil;
  if([self.itemViews count] > index) {
    itemView = self.itemViews[index];
  }
  if(!itemView) {
    itemView = [[[MPPathBarItemView alloc] initWithFrame:NSMakeRect(0, 0, 50, 24)] autorelease];
  }
  itemView.text = [NSString stringWithFormat:@"Button %ld", (unsigned long)index ];
  itemView.image = [NSImage imageNamed:NSImageNameActionTemplate];
  //[itemView setStringValue:[self.delegate pathbar:self stringAtIndex:index]];
  [self.itemViews addObject:itemView];
  return itemView;
}
@end
