//
//  MPEntryInspectorViewController.h
//  MacPass
//
//  Created by Michael Starke on 27.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

@class HNHRoundedSecureTextField;
@class MPDocument;

@interface MPEntryInspectorViewController : MPViewController <NSPopoverDelegate>

@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSTextField *usernameTextField;
@property (weak) IBOutlet NSTextField *URLTextField;
@property (weak) IBOutlet HNHRoundedSecureTextField *passwordTextField;

@property (weak) IBOutlet NSTextField *createdTextField;
@property (weak) IBOutlet NSTextField *modifiedTextField;

@property (weak) IBOutlet NSSegmentedControl *infoTabControl;
@property (weak) IBOutlet NSTableView *attachmentTableView;
@property (weak) IBOutlet NSTableView *customFieldsTableView;
@property (weak) IBOutlet NSTableView *historyTableView;
@property (unsafe_unretained) IBOutlet NSTextView *notesTextView;
@property (weak) IBOutlet NSButton *generatePasswordButton;
@property (weak) IBOutlet NSButton *togglePassword;

@property (weak) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSView *generalView;

@property (weak) IBOutlet NSButton *expiresCheckButton;
@property (weak) IBOutlet NSTokenField *tagsTokenField;

- (void)setupBindings:(MPDocument *)document;

- (IBAction)saveAttachment:(id)sender;
- (IBAction)addAttachment:(id)sender;
- (IBAction)removeAttachment:(id)sender;

- (IBAction)addCustomField:(id)sender;
- (IBAction)removeCustomField:(id)sender;



@end
