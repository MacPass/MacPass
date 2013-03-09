//
//  MPMainWindowSplitViewDelegate.m
//  MacPass
//
//  Created by michael starke on 18.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPMainWindowSplitViewDelegate.h"

const CGFloat MPMainWindowSplitViewDelegateMinimumOutlineWidth = 150.0;
const CGFloat MPMainWindowSplitViewDelegateMinimumContentWidth = 250.0;
const CGFloat MPMainWindowSplitViewDelegateMinimumInspectorWidth = 250.0;


@interface MPMainWindowSplitViewDelegate ()

- (NSView *)_subViewOfType:(MPSplitViewSubViewIndex)subViewType splitView:(NSSplitView *)splitView;

@end

@implementation MPMainWindowSplitViewDelegate

- (NSView *)_subViewOfType:(MPSplitViewSubViewIndex)subViewType splitView :(NSSplitView *)splitView {
  return [splitView subviews][subViewType];
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
  return (subview == [self _subViewOfType:MPSplitViewInspectorViewIndex splitView:splitView]);
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
  switch (dividerIndex) {
    case MPSplitViewOutlineDividerIndex:
      return (proposedMinimumPosition < MPMainWindowSplitViewDelegateMinimumOutlineWidth) ? MPMainWindowSplitViewDelegateMinimumOutlineWidth : proposedMinimumPosition;
      break;
      
    case MPSplitViewInspectorDividerIndex: {
      return [self splitView:splitView constrainSplitPosition:proposedMinimumPosition ofSubviewAt:dividerIndex];
    }
      
    default:
      return proposedMinimumPosition;
      break;
  }
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex {
  if(dividerIndex == MPSplitViewInspectorDividerIndex) {
    return [splitView frame].size.width - MPMainWindowSplitViewDelegateMinimumInspectorWidth;
  }
  return proposedPosition;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
  
  // Update to take inpspector into account
  NSView *outlineView = [self _subViewOfType:MPSplitViewOutlineViewIndex splitView:splitView];
  NSView *inspectorView = [self _subViewOfType:MPSplitViewInspectorViewIndex splitView:splitView];
  NSUInteger outlineMultiplicator = [splitView isSubviewCollapsed:outlineView] ? 0 : 1;
  NSUInteger inpsectorMulitplicator = [splitView isSubviewCollapsed:inspectorView] ? 0 : 1;
  NSUInteger dividerMultiplicator = inpsectorMulitplicator + outlineMultiplicator;
  CGFloat availableWidth = [splitView frame].size.width - (dividerMultiplicator * [splitView dividerThickness]);
  switch (dividerIndex) {
    case MPSplitViewOutlineDividerIndex:
      return availableWidth - (outlineMultiplicator * [outlineView frame].size.width ) - MPMainWindowSplitViewDelegateMinimumContentWidth;
      
    case MPSplitViewInspectorDividerIndex:
      return availableWidth - MPMainWindowSplitViewDelegateMinimumInspectorWidth;
      
    default:
      return proposedMaximumPosition;
  }
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize {
  NSSize newSize = [splitView frame].size;
  const CGFloat dividierThickness = [splitView dividerThickness];
  
  NSView *outlineView = [self _subViewOfType:MPSplitViewOutlineViewIndex splitView:splitView];
  NSView *contentView = [self _subViewOfType:MPSplitViewContentViewIndex splitView:splitView];
  NSView *inspectorView = [self _subViewOfType:MPSplitViewInspectorViewIndex splitView:splitView];
  
  CGFloat outlineWidth = [outlineView isHidden] ? 0.0 : [outlineView frame].size.width;
  CGFloat inspectorWidth = [inspectorView isHidden] ? 0.0 : [inspectorView frame].size.width;
  
  CGFloat dividerThicknessCorrection = 0;
  if(outlineWidth > 0.0) {
    dividerThicknessCorrection += dividierThickness;
  }
  if(inspectorWidth > 0.0 ) {
    dividerThicknessCorrection += dividierThickness;
  }
  
  CGFloat contentWidth = newSize.width - outlineWidth - inspectorWidth - dividerThicknessCorrection;
  CGFloat contentOriginX = [outlineView isHidden] ? outlineWidth : outlineWidth + dividierThickness;
  NSRect newContentFrame = NSMakeRect(contentOriginX, 0, contentWidth, newSize.height);
  NSRect newOutlineFrame = NSMakeRect(0, 0, outlineWidth, newSize.height);
  NSRect newInpectorFrame = NSMakeRect(newContentFrame.origin.x + contentWidth + dividierThickness, 0, inspectorWidth, newSize.height);
  
  if(NO == [outlineView isHidden]) {
    [outlineView setFrame:newOutlineFrame];
  }
  if(NO == [inspectorView isHidden]) {
    [inspectorView setFrame:newInpectorFrame];
  }
  [contentView setFrame:newContentFrame];
};

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex {
  NSView *outlineView = [self _subViewOfType:MPSplitViewOutlineViewIndex splitView:splitView];
  NSView *inspectorView = [self _subViewOfType:MPSplitViewInspectorViewIndex splitView:splitView];

  BOOL shouldHide = NO;
  switch (dividerIndex) {
    case MPSplitViewInspectorDividerIndex:
      shouldHide = [inspectorView isHidden];
      break;
      
    case MPSplitViewOutlineDividerIndex:
      shouldHide =  [outlineView isHidden];
      break;
      
    default: {
      NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Divider Index out of range!" userInfo:nil];
      @throw exception;
    }
  }
  return shouldHide;
}

@end
