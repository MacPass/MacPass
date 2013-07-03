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

@property (weak) IBOutlet MPPopupImageView *itemImageView;
@property (weak) IBOutlet NSTextField *itemNameTextfield;

@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSTextField *usernameTextField;
@property (weak) IBOutlet NSTextField *URLTextField;
@property (weak) IBOutlet NSTextField *passwordTextField;
@property (weak) IBOutlet NSTextField *titleOrNameLabel;
@property (weak) IBOutlet HNHGradientView *bottomBar;
@property (weak) IBOutlet NSTextField *createdTextField;
@property (weak) IBOutlet NSTextField *modifiedTextField;
@property (weak) IBOutlet NSSegmentedControl *infoTabControl;
@property (weak) IBOutlet NSTableView *attachmentTableView;
@property (weak) IBOutlet NSTableView *customFieldsTableView;
@property (unsafe_unretained) IBOutlet NSTextView *notesTextView;
@property (weak) IBOutlet NSTextField *customFieldsTextField;


/* Seperate call to ensure alle registered objects are in place */
- (void)setupNotifications:(MPDocumentWindowController *)windowController;

@end
