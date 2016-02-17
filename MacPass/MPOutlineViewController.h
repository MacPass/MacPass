//
//  MPOutlineViewController.h
//  MacPass
//
//  Created by michael starke on 19.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"
#import "MPTargetNodeResolving.h"

APPKIT_EXTERN NSString *const MPOutlineViewDidChangeGroupSelection;

@class HNHUIGradientView;
@class MPDocument;

@interface MPOutlineViewController : MPViewController <MPTargetNodeResolving, NSOutlineViewDelegate, NSMenuDelegate>

- (void)clearSelection;
- (void)showOutline;
- (void)regsiterNotificationsForDocument:(MPDocument *)document;

/**
 *	Retrieves the current item for the current mouse location
 *	@return	Item under mouse. If the mouse isn't inside the view, nil is returned
 */
- (id)itemUnderMouse;

@end
