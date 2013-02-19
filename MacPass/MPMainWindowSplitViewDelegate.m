//
//  MPMainWindowSplitViewDelegate.m
//  MacPass
//
//  Created by michael starke on 18.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPMainWindowSplitViewDelegate.h"

const CGFloat MPMainWindowSplitViewDelegateMinimumOutlineWidth = 150.0;
const CGFloat MPMainWindowSplitViewDelegateMaximumOutlineWidth = 400.0;
const CGFloat MPMainWindowSplitViewDelegateMinimumContentWidth = 400.0;

@interface MPMainWindowSplitViewDelegate ()

- (NSView *)leftView:(NSSplitView *)splitView;
- (NSView *)rightView:(NSSplitView *)splitView;

@end

@implementation MPMainWindowSplitViewDelegate

- (NSView *)leftView:(NSSplitView *)splitView {
  return [splitView subviews][0];
}

- (NSView *)rightView:(NSSplitView *)splitView {
  return [splitView subviews][1];
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
  
  NSView *leftView = [self leftView:splitView];
  NSView *rightView = [self rightView:splitView];
  
  CGFloat leftRelativeWidth = [leftView frame].size.width / oldSize.width;
  CGFloat newLeftWidth = floor(newSize.width * leftRelativeWidth);
  
  if( newLeftWidth < MPMainWindowSplitViewDelegateMinimumOutlineWidth && newSize.width > MPMainWindowSplitViewDelegateMinimumOutlineWidth ) {
    newLeftWidth = MPMainWindowSplitViewDelegateMinimumOutlineWidth;
  }
  if( newLeftWidth > MPMainWindowSplitViewDelegateMaximumOutlineWidth ) {
    newLeftWidth = MPMainWindowSplitViewDelegateMaximumOutlineWidth;
  }
  NSRect newLeftFrame = NSMakeRect(0, 0, newLeftWidth, newSize.height);
  NSRect newRightFrame = NSMakeRect(newLeftWidth + dividierThickness, 0, newSize.width - newLeftWidth - dividierThickness, newSize.height);
  [leftView setFrame:newLeftFrame];
  [rightView setFrame:newRightFrame];
};

@end
