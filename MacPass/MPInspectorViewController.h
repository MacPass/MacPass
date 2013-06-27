//
//  MPInspectorTabViewController.h
//  MacPass
//
//  Created by Michael Starke on 05.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

@class MPPopupImageView;
@class KdbEntry;
@class KdbGroup;
@class HNHGradientView;
@class MPDocumentWindowController;

@interface MPInspectorViewController : MPViewController <NSPopoverDelegate, NSTableViewDelegate>

@property (assign) IBOutlet MPPopupImageView *itemImageView;
@property (assign) IBOutlet NSTextField *itemNameTextfield;

@property (assign) IBOutlet NSTextField *titleTextField;
@property (assign) IBOutlet NSTextField *usernameTextField;
@property (assign) IBOutlet NSTextField *URLTextField;
@property (assign) IBOutlet NSTextField *passwordTextField;
@property (assign) IBOutlet NSTextField *titleOrNameLabel;
@property (assign) IBOutlet HNHGradientView *bottomBar;
@property (assign) IBOutlet NSTextField *createdTextField;
@property (assign) IBOutlet NSTextField *modifiedTextField;
@property (assign) IBOutlet NSSegmentedControl *infoTabControl;
@property (assign) IBOutlet NSTableView *attachmentTableView;
@property (assign) IBOutlet NSTextView *notesTextView;
@property (assign) IBOutlet NSTextField *customFieldsTextField;


/* Seperate call to ensure alle registered objects are in place */
- (void)setupNotifications:(MPDocumentWindowController *)windowController;

@end
