//
//  MPOutlineViewController.h
//  MacPass
//
//  Created by michael starke on 19.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

APPKIT_EXTERN NSString *const MPOutlineViewDidChangeGroupSelection;

@class MPOutlineViewDelegate;
@class HNHGradientView;
@class MPDocumentWindowController;

@interface MPOutlineViewController : MPViewController <NSOutlineViewDelegate, NSMenuDelegate>


@property (weak) IBOutlet HNHGradientView *bottomBar;

- (void)clearSelection;
- (void)showOutline;
- (void)setupNotifications:(MPDocumentWindowController *)windowController;

- (void)createGroup:(id)sender;
- (void)createEntry:(id)sender;
/**
 *	Retrieves the current item for the current mouse location
 *	@return	Item under mouse. If the mouse isn't inside the view, nil is returned
 */
- (id)itemUnderMouse;

@end
