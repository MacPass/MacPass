//
//  MPEntryInspectorViewController.h
//  MacPass
//
//  Created by Michael Starke on 27.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

#import <Quartz/Quartz.h>

@class HNHRoundedSecureTextField;
@class MPDocument;

@interface MPEntryInspectorViewController : MPViewController <NSPopoverDelegate, QLPreviewPanelDelegate>

@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSTextField *usernameTextField;
@property (weak) IBOutlet NSTextField *URLTextField;
@property (weak) IBOutlet HNHRoundedSecureTextField *passwordTextField;

@property (weak) IBOutlet NSTextField *uuidTextField;

@property (weak) IBOutlet NSTextField *createdTextField;
@property (weak) IBOutlet NSTextField *modifiedTextField;

@property (weak) IBOutlet NSSegmentedControl *infoTabControl;
@property (weak) IBOutlet NSTableView *attachmentTableView;
@property (weak) IBOutlet NSTableView *customFieldsTableView;
@property (weak) IBOutlet NSButton *generatePasswordButton;
@property (weak) IBOutlet NSButton *togglePassword;

@property (weak) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSView *generalView;
@property (strong) IBOutlet NSView *autotypView;

@property (weak) IBOutlet NSButton *expiresCheckButton;
@property (weak) IBOutlet NSTokenField *tagsTokenField;

/* Autotype */
@property (weak) IBOutlet NSButton *enableAutotypeCheckButton;
@property (weak) IBOutlet NSButton *obfuscateAutotypeCheckButton;
@property (weak) IBOutlet NSTableView *windowAssociationsTableView;
@property (weak) IBOutlet NSTextField *customEntrySequenceTextField;
@property (weak) IBOutlet NSComboBox *windowTitleComboBox;

@property (weak) IBOutlet NSButton *removeAssociationButton;
@property (weak) IBOutlet NSButton *addAssociationButton;

@property (weak) IBOutlet NSTextField *associationSequenceTextField;

- (void)setupBindings:(MPDocument *)document;
- (void)regsiterNotificationsForDocument:(MPDocument *)document;

- (IBAction)saveAttachment:(id)sender;
- (IBAction)addAttachment:(id)sender;
- (IBAction)removeAttachment:(id)sender;

- (IBAction)addCustomField:(id)sender;
- (IBAction)removeCustomField:(id)sender;

- (IBAction)addWindowAssociation:(id)sender;
- (IBAction)removeWindowAssociation:(id)sender;

- (IBAction)toggleQuicklookPreview:(id)sender;

- (void)beginEditing;
- (void)endEditing;


@end
