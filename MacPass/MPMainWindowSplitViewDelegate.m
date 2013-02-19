//
//  MPMainWindowSplitViewDelegate.m
//  MacPass
//
//  Created by michael starke on 18.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPMainWindowSplitViewDelegate.h"

const CGFloat _minimumSplitterWidth = 10.0;

@implementation MPMainWindowSplitViewDelegate

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
  return _minimumSplitterWidth;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
  NSView *otherView= [splitView subviews][(dividerIndex + 1) % 2];
  
  CGFloat maximumWidth = [splitView frame].size.width - ( [splitView dividerThickness] + [otherView frame].size.width + _minimumSplitterWidth );
  return maximumWidth;
}

@end
