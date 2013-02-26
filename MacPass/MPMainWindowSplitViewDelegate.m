//
//  MPMainWindowSplitViewDelegate.m
//  MacPass
//
//  Created by michael starke on 18.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPMainWindowSplitViewDelegate.h"

const CGFloat MPMainWindowSplitViewDelegateMinimumOutlineWidth = 150.0;
const CGFloat MPMainWindowSplitViewDelegateMinimumContentWidth = 400.0;

@interface MPMainWindowSplitViewDelegate ()

- (NSView *)_leftView:(NSSplitView *)splitView;
- (NSView *)_rightView:(NSSplitView *)splitView;

@end

@implementation MPMainWindowSplitViewDelegate

- (NSView *)_leftView:(NSSplitView *)splitView {
  return [splitView subviews][0];
}

- (NSView *)_rightView:(NSSplitView *)splitView {
  return [splitView subviews][1];
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
  return (subview == [self _leftView:splitView]);
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
  return (proposedMinimumPosition < MPMainWindowSplitViewDelegateMinimumOutlineWidth) ? MPMainWindowSplitViewDelegateMinimumOutlineWidth : proposedMinimumPosition;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
  CGFloat availableWidth = [splitView frame].size.width - [splitView dividerThickness];
  return (availableWidth - MPMainWindowSplitViewDelegateMinimumOutlineWidth);
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize {
  NSSize newSize = [splitView frame].size;
  const CGFloat dividierThickness = [splitView dividerThickness];
  
  NSView *leftView = [self _leftView:splitView];
  NSView *rightView = [self _rightView:splitView];
  
  CGFloat leftWidth = [leftView isHidden] ? 0.0 : [leftView frame].size.width;
  NSRect newRightFrame = NSMakeRect(leftWidth + dividierThickness, 0, newSize.width - leftWidth - dividierThickness, newSize.height);
  NSRect newLeftFrame = NSMakeRect(0, 0, leftWidth, newSize.height);
  if(NO == [leftView isHidden]) {
    [leftView setFrame:newLeftFrame];
  }
  [rightView setFrame:newRightFrame];
};

@end
