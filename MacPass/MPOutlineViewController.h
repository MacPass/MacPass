//
//  MPOutlineViewController.h
//  MacPass
//
//  Created by michael starke on 19.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

@class MPOutlineViewDelegate;
@class KdbGroup;
@class HNHGradientView;
@class MPDocumentWindowController;

@interface MPOutlineViewController : MPViewController

@property (readonly, assign) NSOutlineView *outlineView;
@property (retain, readonly) MPOutlineViewDelegate *outlineDelegate;
@property (assign) IBOutlet HNHGradientView *bottomBar;

- (void)showOutline;
- (void)setupNotifications:(MPDocumentWindowController *)windowController;

- (void)createGroup:(id)sender;
- (void)createEntry:(id)sender;
- (void)deleteEntry:(id)sender;

@end
