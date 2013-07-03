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
@class KdbGroup;
@class HNHGradientView;
@class MPDocumentWindowController;

@interface MPOutlineViewController : MPViewController <NSOutlineViewDelegate>

@property (readonly, weak) NSOutlineView *outlineView;
@property (weak) IBOutlet HNHGradientView *bottomBar;
@property (weak, readonly) KdbGroup *selectedGroup;

- (void)clearSelection;
- (void)showOutline;
- (void)setupNotifications:(MPDocumentWindowController *)windowController;

- (void)createGroup:(id)sender;
- (void)createEntry:(id)sender;
- (void)deleteNode:(id)sender;

@end
