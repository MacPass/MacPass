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

@interface MPInspectorViewController : MPViewController <NSPopoverDelegate>

@property (weak) IBOutlet HNHGradientView *bottomBar;
@property (weak) IBOutlet NSTextField *createdTextField;
@property (weak) IBOutlet NSTextField *modifiedTextField;
@property (weak) IBOutlet NSTextField *noSelectionInfo;
@property (weak) IBOutlet MPPopupImageView *itemImageView;
@property (weak) IBOutlet NSTextField *itemNameTextField;

- (IBAction)showImagePopup:(id)sender;

/* Seperate call to ensure alle registered objects are in place */
- (void)setupNotifications:(NSWindowController *)windowController;

@end
