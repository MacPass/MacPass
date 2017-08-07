//
//  MPEntryInspectorViewController.h
//  MacPass
//
//  Created by Michael Starke on 27.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

#import <Quartz/Quartz.h>

@class HNHUIRoundedSecureTextField;
@class MPDocument;

@interface MPEntryInspectorViewController : MPViewController <NSPopoverDelegate, QLPreviewPanelDelegate>

@property (weak) IBOutlet NSSegmentedControl *infoTabControl;

/* General */
@property (weak) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSView *generalView;

@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSTextField *usernameTextField;
@property (weak) IBOutlet NSTextField *URLTextField;
@property (weak) IBOutlet HNHUIRoundedSecureTextField *passwordTextField;
@property (weak) IBOutlet NSButton *generatePasswordButton;
@property (weak) IBOutlet NSButton *togglePassword;
@property (weak) IBOutlet NSButton *pickExpireDateButton;
@property (weak) IBOutlet NSButton *expiresCheckButton;
@property (weak) IBOutlet NSTokenField *tagsTokenField;
@property (weak) IBOutlet NSTextField *uuidTextField;

@property (weak) IBOutlet NSTextField *createdTextField;
@property (weak) IBOutlet NSTextField *modifiedTextField;
@property (weak) IBOutlet NSButton *addCustomFieldButton;

/* Attachments */
@property (weak) IBOutlet NSButtonCell *addAttachmentButton;

@property (weak) IBOutlet NSTableView *attachmentTableView;

/* Custom Fields */
@property (strong) IBOutlet NSTableView *customFieldsTableView;
@property (weak) IBOutlet NSButton *showCustomDataButton;

/* Autotype */
@property (strong) IBOutlet NSView *autotypView;
@property (weak) IBOutlet NSButton *enableAutotypeCheckButton;
@property (weak) IBOutlet NSButton *obfuscateAutotypeCheckButton;
@property (weak) IBOutlet NSTableView *windowAssociationsTableView;
@property (weak) IBOutlet NSButton *showCustomEntrySequenceAutotypeBuilderButton;
@property (weak) IBOutlet NSTextField *customEntrySequenceTextField;
@property (weak) IBOutlet NSComboBox *windowTitleComboBox;

@property (weak) IBOutlet NSButton *showCustomAssociationSequenceAutotypeBuilderButton;

@property (weak) IBOutlet NSTextField *associationSequenceTextField;
@property (weak) IBOutlet NSButton *addWindowAssociationButton;
@property (weak) IBOutlet NSButton *removeWindowAssociationButton;

- (void)registerNotificationsForDocument:(MPDocument *)document;

- (IBAction)showPasswordGenerator:(id)sender;

- (IBAction)saveAttachment:(id)sender;
- (IBAction)addAttachment:(id)sender;
- (IBAction)removeAttachment:(id)sender;

- (IBAction)addCustomField:(id)sender;
- (IBAction)removeCustomField:(id)sender;

- (IBAction)addWindowAssociation:(id)sender;
- (IBAction)removeWindowAssociation:(id)sender;

- (IBAction)toggleQuicklookPreview:(id)sender;
- (IBAction)toggleExpire:(NSButton*)sender;
@end
