//
//  MPMainWindowSplitViewDelegate.h
//  MacPass
//
//  Created by michael starke on 18.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

APPKIT_EXTERN const CGFloat MPMainWindowSplitViewDelegateMinimumOutlineWidth;
APPKIT_EXTERN const CGFloat MPMainWindowSplitViewDelegateMinimumContentWidth;
APPKIT_EXTERN const CGFloat MPMainWindowSplitViewDelegateMinimumInspectorWidth;

typedef enum {
  MPSplitViewOutlineViewIndex,
  MPSplitViewContentViewIndex,
  MPSplitViewInspectorViewIndex,
} MPSplitViewSubViewIndex;

@interface MPMainWindowSplitViewDelegate : NSObject <NSSplitViewDelegate>


@end
