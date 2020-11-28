//
//  MPEntryInspectorViewController.h
//  MacPass
//
//  Created by Michael Starke on 27.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "MPViewController.h"
#import "HNHUi/HNHUi.h"
#import <Quartz/Quartz.h>

@class HNHUISecureTextField;
@class MPContextButton;
@class MPDocument;

@interface MPEntryInspectorViewController : MPViewController <NSPopoverDelegate, QLPreviewPanelDelegate, HNHUITextFieldDelegate>

@property (weak) IBOutlet NSSegmentedControl *infoTabControl;

/* General */
@property (weak) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSView *generalView;

@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSTextField *usernameTextField;
@property (weak) IBOutlet NSTextField *URLTextField;
@property (weak) IBOutlet HNHUISecureTextField *passwordTextField;
@property (weak) IBOutlet NSButton *generatePasswordButton;
@property (weak) IBOutlet NSButton *togglePassword;
@property (weak) IBOutlet NSButton *pickExpireDateButton;
@property (weak) IBOutlet NSButton *expiresCheckButton;
@property (weak) IBOutlet NSTokenField *tagsTokenField;
@property (weak) IBOutlet NSTextField *uuidTextField;

@property (weak) IBOutlet MPContextButton *addCustomFieldButton;
@property (strong) IBOutlet NSStackView *fieldsStackView;

/* Attachments */
@property (weak) IBOutlet NSButtonCell *addAttachmentButton;

@property (weak) IBOutlet NSTableView *attachmentTableView;

/* Custom Fields */
@property (strong) IBOutlet NSTableView *customFieldsTableView;
@property (weak) IBOutlet NSButton *showCustomDataButton;

/* TOTP */
@property (strong) IBOutlet NSProgressIndicator *totpProgressIndicator;
@property (strong) IBOutlet NSTextField *totpLabelTextField;
@property (strong) IBOutlet NSTextField *totpCodeTextField;

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
- (IBAction)showReferenceBuilder:(id)sender;
- (IBAction)showAutotypeBuilder:(id)sender;

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
