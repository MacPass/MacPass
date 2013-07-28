//
//  MPInspectorTabViewController.h
//  MacPass
//
//  Created by Michael Starke on 05.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

@class HNHGradientView;
@class MPPopupImageView;

@interface MPInspectorViewController : MPViewController

@property (weak) IBOutlet HNHGradientView *bottomBar;
@property (weak) IBOutlet NSTextField *createdTextField;
@property (weak) IBOutlet NSTextField *modifiedTextField;
@property (weak) IBOutlet NSImageView *modifiedImageView;
@property (weak) IBOutlet NSImageView *createdImageView;
@property (weak) IBOutlet NSTextField *noSelectionInfo;
@property (weak) IBOutlet MPPopupImageView *itemImageView;
@property (weak) IBOutlet NSTextField *itemNameTextField;

/* Seperate call to ensure alle registered objects are in place */
- (void)setupNotifications:(NSWindowController *)windowController;

@end
