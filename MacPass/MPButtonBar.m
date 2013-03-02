//
//  MPButtonBar.m
//  MacPass
//
//  Created by michael starke on 28.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPButtonBar.h"
#import "MPButtonBarButton.h"

#define MPBUTTONBAR_BUTTON_MARGIN 5.0;

NSString *const MPButtonBarSelectionChangedNotification = @"MPButtonBarSelectionChangedNotification";
NSString *const MPButtonBarSelectionIndexKey = @"MPButtonBarSelectionIndexKey";

NSString *const MPButtonBarInvalidDelegateException = @"MPButtonBarInvalidDelegateException";


@interface MPButtonBar ()

@property (retain) NSMutableArray *buttons;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (assign) BOOL delegateSupportsImage;
@property (assign) BOOL delegateSupportsLabel;

- (void)_updateButtons;
- (void)_didClickButton:(id)sender;

@end

@implementation MPButtonBar

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.selectedIndex = NSNotFound;
    self.buttons = [NSMutableArray arrayWithCapacity:5];
    self.delegateSupportsImage = NO;
    self.delegateSupportsLabel = NO;
    [self _updateButtons];
  }
  return self;
}

# pragma mark Layout

- (void)_updateButtons {
  NSUInteger currentButtonCount = [self.buttons count];
  NSUInteger newButtonCount = 5;//[self.delegate buttonsInButtonBar:self];
  /*
   remove unused buttons
   */
  if(currentButtonCount > newButtonCount) {
    NSRange removalRange = NSMakeRange(newButtonCount - 1, currentButtonCount - newButtonCount);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:removalRange];
    NSArray *obsolteButtons = [self.buttons objectsAtIndexes:indexSet];
    for(NSButton *button in obsolteButtons) {
      [button removeFromSuperviewWithoutNeedingDisplay];
    }
    [self.buttons removeObjectsInRange:NSMakeRange(newButtonCount - 1, currentButtonCount - newButtonCount)];
  }
  CGFloat startPosition = MPBUTTONBAR_BUTTON_MARGIN;
  for(NSUInteger buttonIndex = 0; buttonIndex < newButtonCount ; buttonIndex++) {
    BOOL needsDisplay = NO;
    if(buttonIndex >= currentButtonCount) {
      NSButton *newButton= [[MPButtonBarButton alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
      [self addSubview:newButton];
      [self.buttons addObject:newButton];
      [newButton release];
      [newButton setTarget:self];
      [newButton setImage:[NSImage imageNamed:NSImageNameActionTemplate]];
      [newButton setAction:@selector(_didClickButton:)];
      needsDisplay = YES;
    }
    NSButton *currentButton = self.buttons[buttonIndex];
    if (self.delegateSupportsImage) {
      [currentButton setImage:[self.delegate buttonBar:self imageAtIndex:buttonIndex]];
      needsDisplay = YES;
    }
    if(self.delegateSupportsLabel) {
      [currentButton setStringValue:[self.delegate buttonBar:self labelAtIndex:buttonIndex]];
      needsDisplay = YES;
    }
    [currentButton sizeToFit];
    NSRect frame = [currentButton frame];
    frame.size.width += 20;
    frame.origin.x = startPosition;
    [currentButton setFrame:frame];
    startPosition += frame.size.width + MPBUTTONBAR_BUTTON_MARGIN;
    [self setNeedsDisplay:needsDisplay];
  }
}

#pragma mark Button Events

- (void)_didClickButton:(id)sender {
  NSUInteger index = [[self subviews] indexOfObject:sender];
  if(index == NSNotFound) {
    return; // Nothing we need to know about happened;
  }
  NSDictionary *userInfo = @{ MPButtonBarSelectionIndexKey: @(index) };
  [[NSNotificationCenter defaultCenter] postNotificationName:MPButtonBarSelectionChangedNotification object:self userInfo:userInfo];
}

# pragma mark Properties

- (void)setDelegate:(id<MPButtonBarDelegate>)delegate {
  if( ![delegate conformsToProtocol:@protocol(MPButtonBarDelegate)]) {
    NSException *invalidDelegateException = [NSException exceptionWithName:MPButtonBarInvalidDelegateException reason:@"The Delegate does not conform to the MPButtonBarDelegate protocoll" userInfo:nil];
    @throw invalidDelegateException;
  }
  if(_delegate != delegate) {
    if([_delegate respondsToSelector:@selector(didChangeButtonSelection:)]) {
      [[NSNotificationCenter defaultCenter] removeObserver:_delegate];
    }
    _delegate = delegate;
    self.delegateSupportsLabel = [delegate respondsToSelector:@selector(buttonBar:labelAtIndex:)];
    self.delegateSupportsImage = [delegate respondsToSelector:@selector(buttonBar:imageAtIndex:)];
    if([delegate respondsToSelector:@selector(selectionDidChanged:)]) {
      [[NSNotificationCenter defaultCenter] addObserver:self.delegate selector:@selector(didChangeButtonSelection:) name:MPButtonBarSelectionChangedNotification object:self];
    }
    [self _updateButtons];
  }
}

- (BOOL)hasSelection {
  return self.selectedIndex != NSNotFound;
}

@end