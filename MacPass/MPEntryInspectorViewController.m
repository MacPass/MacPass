//
//  MPEntryInspectorViewController.m
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

#import "MPEntryInspectorViewController.h"
#import "MPAttachmentTableDataSource.h"
#import "MPAttachmentTableViewDelegate.h"
#import "MPCustomFieldTableViewDelegate.h"
#import "MPPasswordCreatorViewController.h"
#import "MPWindowAssociationsTableViewDelegate.h"
#import "MPWindowTitleComboBoxDelegate.h"
#import "MPAutotypeBuilderViewController.h"

#import "NSString+MPPasswordCreation.h"

#import "MPDocument.h"
#import "MPIconHelper.h"
#import "MPValueTransformerHelper.h"
#import "MPTemporaryFileStorage.h"
#import "MPTemporaryFileStorageCenter.h"
#import "MPActionHelper.h"
#import "MPSettingsHelper.h"

#import "MPArrayController.h"

#import "KeePassKit/KeePassKit.h"

#import "HNHUi/HNHUi.h"

typedef NS_ENUM(NSUInteger, MPEntryTab) {
  MPEntryTabGeneral,
  MPEntryTabFiles,
  MPEntryTabAutotype
};

@interface MPEntryInspectorViewController () {
@private
  NSArrayController *_attachmentsController;
  NSArrayController *_customFieldsController;
  MPArrayController *_windowAssociationsController;
  MPAttachmentTableViewDelegate *_attachmentTableDelegate;
  MPCustomFieldTableViewDelegate *_customFieldTableDelegate;
  MPAttachmentTableDataSource *_attachmentDataSource;
  MPWindowAssociationsTableViewDelegate *_windowAssociationsTableDelegate;
  MPWindowTitleComboBoxDelegate *_windowTitleMenuDelegate;
}

@property (nonatomic, assign) BOOL showPassword;
@property (nonatomic, assign) MPEntryTab activeTab;
@property (strong) NSPopover *activePopover;
@property (nonatomic, readonly) KPKEntry *representedEntry;

@property (strong) MPTemporaryFileStorage *quicklookStorage;

@end

@implementation MPEntryInspectorViewController

- (NSString *)nibName {
  return @"EntryInspectorView";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _showPassword = NO;
    _attachmentsController = [[NSArrayController alloc] init];
    _customFieldsController = [[NSArrayController alloc] init];
    _windowAssociationsController = [[MPArrayController alloc] init];
    _attachmentTableDelegate = [[MPAttachmentTableViewDelegate alloc] init];
    _customFieldTableDelegate = [[MPCustomFieldTableViewDelegate alloc] init];
    _attachmentDataSource = [[MPAttachmentTableDataSource alloc] init];
    _windowAssociationsTableDelegate = [[MPWindowAssociationsTableViewDelegate alloc] init];
    _windowTitleMenuDelegate = [[MPWindowTitleComboBoxDelegate alloc] init];
    _attachmentTableDelegate.viewController = self;
    _customFieldTableDelegate.viewController = self;
    _activeTab = MPEntryTabGeneral;
  }
  return self;
}

- (KPKEntry *)representedEntry {
  if([self.representedObject isKindOfClass:[KPKEntry class]]) {
    return self.representedObject;
  }
  return nil;
}

- (void)viewDidLoad {
  
  [self _addScrollViewWithView:self.generalView atTab:MPEntryTabGeneral];
  [self _addScrollViewWithView:self.autotypView atTab:MPEntryTabAutotype];
  
  [self.infoTabControl bind:NSSelectedIndexBinding toObject:self withKeyPath:NSStringFromSelector(@selector(activeTab)) options:nil];
  [self.tabView bind:NSSelectedIndexBinding toObject:self withKeyPath:NSStringFromSelector(@selector(activeTab)) options:nil];
  
  
  self.attachmentTableView.backgroundColor = [NSColor clearColor];
  [self.attachmentTableView bind:NSContentBinding toObject:_attachmentsController withKeyPath:NSStringFromSelector(@selector(arrangedObjects)) options:nil];
  self.attachmentTableView.delegate = _attachmentTableDelegate;
  self.attachmentTableView.dataSource = _attachmentDataSource;
  [self.attachmentTableView registerForDraggedTypes:@[NSFilenamesPboardType]];
  
  /* extract custom field table view */
  self.customFieldsTableView.translatesAutoresizingMaskIntoConstraints = NO;
  NSView *customFieldTableView = self.customFieldsTableView;
  [self.customFieldsTableView.enclosingScrollView removeFromSuperviewWithoutNeedingDisplay];
  
  
  [self.generalView addSubview:customFieldTableView];
  
  NSDictionary *dict = NSDictionaryOfVariableBindings(customFieldTableView, _tagsTokenField, _addCustomFieldButton);
  [self.generalView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[customFieldTableView]-16-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:dict]];
  [self.generalView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tagsTokenField]-[customFieldTableView]-[_addCustomFieldButton]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:dict]];
  
  
  
  
  self.customFieldsTableView.backgroundColor = NSColor.clearColor;
  [self.customFieldsTableView bind:NSContentBinding toObject:_customFieldsController withKeyPath:NSStringFromSelector(@selector(arrangedObjects)) options:nil];
  self.customFieldsTableView.delegate = _customFieldTableDelegate;
  
  [self.customFieldsTableView sizeLastColumnToFit];
  
  self.windowAssociationsTableView.backgroundColor = NSColor.clearColor;
  self.windowAssociationsTableView.delegate = _windowAssociationsTableDelegate;
  [self.windowAssociationsTableView bind:NSContentBinding toObject:_windowAssociationsController withKeyPath:NSStringFromSelector(@selector(arrangedObjects)) options:nil];
  [self.windowAssociationsTableView bind:NSSelectionIndexesBinding toObject:_windowAssociationsController withKeyPath:NSSelectionIndexesBinding options:nil];
  
  self.windowTitleComboBox.delegate = _windowTitleMenuDelegate;
  
  [self.passwordTextField bind:NSStringFromSelector(@selector(showPassword)) toObject:self withKeyPath:NSStringFromSelector(@selector(showPassword)) options:nil];
  [self.togglePassword bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(showPassword)) options:nil];
  
  [self _setupViewBindings];
}

- (void)registerNotificationsForDocument:(MPDocument *)document {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didAddEntry:)
                                               name:MPDocumentDidAddEntryNotification
                                             object:document];
  _windowAssociationsController.observer = document;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Actions

- (void)addCustomField:(id)sender {
  [self.observer willChangeModelProperty];
  [self.windowController.document createCustomAttribute:self.representedObject];
  [self.observer didChangeModelProperty];
}
- (void)removeCustomField:(id)sender {
  NSUInteger index = [sender tag];
  KPKAttribute *attribute = self.representedEntry.customAttributes[index];
  [self.observer willChangeModelProperty];
  [self.representedEntry removeCustomAttribute:attribute];
  [self.observer didChangeModelProperty];
}

- (void)saveAttachment:(id)sender {
  NSInteger row = [self.attachmentTableView selectedRow];
  if(row < 0) {
    return; // No selection
  }
  KPKBinary *binary = self.representedEntry.binaries[row];
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  savePanel.canCreateDirectories = YES;
  savePanel.nameFieldStringValue = binary.name;
  
  [savePanel beginSheetModalForWindow:self.windowController.window completionHandler:^(NSInteger result) {
    if(result == NSFileHandlingPanelOKButton) {
      NSError *error;
      BOOL sucess = [binary saveToLocation:savePanel.URL error:&error];
      if(!sucess && error) {
        [NSApp presentError:error];
      }
    }
  }];
}

- (void)addAttachment:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  openPanel.canChooseDirectories = NO;
  openPanel.canChooseFiles = YES;
  openPanel.allowsMultipleSelection = YES;
  [openPanel beginSheetModalForWindow:self.windowController.window completionHandler:^(NSInteger result) {
    if(result == NSFileHandlingPanelOKButton) {
      for (NSURL *attachmentURL in openPanel.URLs) {
        KPKBinary *binary = [[KPKBinary alloc] initWithContentsOfURL:attachmentURL];
        [self.observer willChangeModelProperty];
        [self.representedEntry addBinary:binary];
        [self.observer didChangeModelProperty];
      }
    }
  }];
}

- (void)removeAttachment:(id)sender {
  NSInteger row = self.attachmentTableView.selectedRow;
  if(row < 0) {
    return; // no selection
  }
  KPKBinary *binary = self.representedEntry.binaries[row];
  [self.observer willChangeModelProperty];
  [self.representedEntry removeBinary:binary];
  [self.observer didChangeModelProperty];
}

- (void)addWindowAssociation:(id)sender {
  KPKWindowAssociation *associtation = [[KPKWindowAssociation alloc] initWithWindowTitle:NSLocalizedString(@"DEFAULT_WINDOW_TITLE", "") keystrokeSequence:nil];
  [self.observer willChangeModelProperty];
  [self.representedEntry.autotype addAssociation:associtation];
  [self.observer didChangeModelProperty];
}

- (void)removeWindowAssociation:(id)sender {
  NSInteger row = self.windowAssociationsTableView.selectedRow;
  if(row > - 1 && row < self.representedEntry.autotype.associations.count) {
    [self.observer willChangeModelProperty];
    KPKWindowAssociation *association = self.representedEntry.autotype.associations[row];
    if(association) {
      [self.representedEntry.autotype removeAssociation:association];
      [self.observer didChangeModelProperty];
    }
  }
}

- (void)toggleQuicklookPreview:(id)sender {
  if([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible]) {
    QLPreviewPanel *panel = [QLPreviewPanel sharedPreviewPanel];
    if([self acceptsPreviewPanelControl:nil]) {
      [self _updatePreviewItemForPanel:panel];
      [panel reloadData];
    }
    else {
      [panel orderOut:sender];
    }
  }
  else {
    [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:sender];
  }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  switch([MPActionHelper typeForAction:menuItem.action]) {
    case MPActionToggleQuicklook: {
      BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyEnableQuicklookPreview];
      return enabled ? [self acceptsPreviewPanelControl:nil] : NO;
    case MPActionRemoveAttachment:
      return !self.representedEntry.isHistory;
    }
    default:
      return YES;
  }
}

#pragma mark -
#pragma mark QLPreviewPanelDelegate

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel {
  if(self.activeTab == MPEntryTabFiles) {
    return (self.attachmentTableView.selectedRow != -1);
  }
  return NO;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel {
  [self _updatePreviewItemForPanel:panel];
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel {
  MPTemporaryFileStorage *storage = (MPTemporaryFileStorage *)panel.dataSource;
  [[MPTemporaryFileStorageCenter defaultCenter] unregisterStorage:storage];
}

- (void)_updatePreviewItemForPanel:(QLPreviewPanel *)panel {
  NSInteger row = [self.attachmentTableView selectedRow];
  NSAssert(row > -1, @"Row needs to be selected");
  KPKBinary *binary = self.representedEntry.binaries[row];
  MPTemporaryFileStorage *oldStorage = (MPTemporaryFileStorage *)panel.dataSource;
  [[MPTemporaryFileStorageCenter defaultCenter] unregisterStorage:oldStorage];
  panel.dataSource = [[MPTemporaryFileStorageCenter defaultCenter] storageForBinary:binary];
}

#pragma mark -
#pragma mark Popovers

- (IBAction)showAutotypeBuilder:(id)sender {
  [sender setEnabled:NO];
  MPAutotypeBuilderViewController *autotypeBuilder = [[MPAutotypeBuilderViewController alloc] init];
  autotypeBuilder.representedObject = self.representedObject;
  [self _showPopopver:autotypeBuilder atView:sender onEdge:NSMinYEdge];
}

- (IBAction)showPasswordGenerator:(id)sender {
  self.generatePasswordButton.enabled = NO;
  MPPasswordCreatorViewController *viewController = [[MPPasswordCreatorViewController alloc] init];
  viewController.allowsEntryDefaults = YES;
  viewController.representedObject = self.representedObject;
  viewController.observer = self.windowController.document;
  [self _showPopopver:viewController atView:sender onEdge:NSMinYEdge];
}

- (void)_showPopopver:(NSViewController *)viewController atView:(NSView *)view onEdge:(NSRectEdge)edge {
  if(self.activePopover.contentViewController == viewController) {
    return; // Do nothing, we already did show the controller
  }
  [self.activePopover close];
  NSAssert(self.activePopover == nil, @"Popover hast to be niled out");
  self.activePopover = [[NSPopover alloc] init];
  self.activePopover.delegate = self;
  self.activePopover.behavior = NSPopoverBehaviorTransient;
  self.activePopover.contentViewController = viewController;
  [self.activePopover showRelativeToRect:NSZeroRect ofView:view preferredEdge:edge];
}

- (void)popoverDidClose:(NSNotification *)notification {
  self.generatePasswordButton.enabled = YES;
  self.showCustomEntrySequenceAutotypeBuilderButton.enabled = YES;
  self.showCustomAssociationSequenceAutotypeBuilderButton.enabled = YES;
  self.activePopover = nil;
}

#pragma mark -
#pragma mark UI Setup
- (void)_addScrollViewWithView:(NSView *)view atTab:(MPEntryTab)tab {
  /* ScrollView setup for the General Tab */
  
  HNHUIScrollView *scrollView = [[HNHUIScrollView alloc] init];
  scrollView.actAsFlipped = NO;
  scrollView.showBottomShadow = NO;
  scrollView.hasVerticalScroller = YES;
  scrollView.drawsBackground = NO;
  scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  NSView *clipView = scrollView.contentView;
  
  NSTabViewItem *tabViewItem = [self.tabView tabViewItemAtIndex:tab];
  NSView *tabView = tabViewItem.view;
  /*
   DO NEVER SET setTranslatesAutoresizingMaskIntoConstraints on NSTabViewItem's view
   [tabView setTranslatesAutoresizingMaskIntoConstraints:NO];
   */
  scrollView.documentView = view;
  [tabView addSubview:scrollView];
  tabViewItem.initialFirstResponder = scrollView;
  
  NSDictionary *views = NSDictionaryOfVariableBindings(view, scrollView);
  [scrollView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:views ]];
  [scrollView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:views]];
  [clipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views]];
  [clipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views]];
  
  [[self view] layoutSubtreeIfNeeded];
}

#pragma mark -
#pragma mark Entry Selection
- (void)_setupViewBindings {
  /* Disable for history view */
  NSArray *inputs = @[self.titleTextField,
                      self.passwordTextField,
                      self.usernameTextField,
                      self.URLTextField,
                      self.expiresCheckButton,
                      self.tagsTokenField,
                      self.generatePasswordButton,
                      self.addAttachmentButton,
                      self.addCustomFieldButton,
                      self.addWindowAssociationButton,
                      self.removeWindowAssociationButton,
                      self.enableAutotypeCheckButton,
                      self.obfuscateAutotypeCheckButton,
                      self.customEntrySequenceTextField,
                      self.windowTitleComboBox,
                      self.associationSequenceTextField];
  
  for(NSControl *control in inputs) {
    [control bind:NSEnabledBinding
         toObject:self
      withKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(isHistory))]
          options:@{NSConditionallySetsEditableBindingOption: @NO, NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
  }
  
  /* general */
  [self.titleTextField bind:NSValueBinding
                   toObject:self
                withKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(title))]
                    options:@{ NSNullPlaceholderBindingOption: NSLocalizedString(@"NONE", "")} ];
  [self.passwordTextField bind:NSValueBinding
                      toObject:self
                   withKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(password))]
                       options:@{ NSNullPlaceholderBindingOption: NSLocalizedString(@"NONE", "") }];
  [self.usernameTextField bind:NSValueBinding
                      toObject:self
                   withKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(username))]
                       options:@{ NSNullPlaceholderBindingOption: NSLocalizedString(@"NONE", "") }];
  [self.URLTextField bind:NSValueBinding
                 toObject:self
              withKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(url))]
                  options:@{ NSNullPlaceholderBindingOption: NSLocalizedString(@"NONE", "")}];
  [self.expiresCheckButton bind:NSTitleBinding
                       toObject:self
                    withKeyPath:[NSString stringWithFormat:@"%@.%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(timeInfo)), NSStringFromSelector(@selector(expirationDate))]
                        options:@{ NSValueTransformerNameBindingOption:MPExpiryDateValueTransformerName }];
  [self.expiresCheckButton bind:NSValueBinding
                       toObject:self
                    withKeyPath:[NSString stringWithFormat:@"%@.%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(timeInfo)), NSStringFromSelector(@selector(expires))]
                        options:nil];
  [self.tagsTokenField bind:NSValueBinding
                   toObject:self
                withKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(tags))]
                    options:nil];
  
  
  [self.uuidTextField bind:NSValueBinding
                  toObject:self
               withKeyPath:[NSString stringWithFormat:@"%@.%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(uuid)), NSStringFromSelector(@selector(UUIDString))]
                   options:@{ NSConditionallySetsEditableBindingOption: @NO }];
  self.uuidTextField.editable = NO;
  
  /* Attachments */
  [_attachmentsController bind:NSContentArrayBinding
                      toObject:self
                   withKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(binaries))]
                       options:nil];
  
  /* CustomField */
  [_customFieldsController bind:NSContentArrayBinding
                       toObject:self
                    withKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(customAttributes))]
                        options:nil];
  
  /* Autotype */
  [self.enableAutotypeCheckButton bind:NSValueBinding
                              toObject:self
                           withKeyPath:[NSString stringWithFormat:@"%@.%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(autotype)), NSStringFromSelector(@selector(enabled))] options:nil];
  [self.obfuscateAutotypeCheckButton bind:NSValueBinding
                                 toObject:self
                              withKeyPath:[NSString stringWithFormat:@"%@.%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(autotype)), NSStringFromSelector(@selector(obfuscateDataTransfer))]
                                  options:nil];
  
  /* Use enabled2 since NSEnabledBinding is already bound! */
  [self.customEntrySequenceTextField bind:@"enabled2"
                                 toObject:self
                              withKeyPath:[NSString stringWithFormat:@"%@.%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(autotype)), NSStringFromSelector(@selector(enabled))]
                                  options:nil];
  
  
  [self.customEntrySequenceTextField bind:NSValueBinding
                                 toObject:self
                              withKeyPath:[NSString stringWithFormat:@"%@.%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(autotype)), NSStringFromSelector(@selector(defaultKeystrokeSequence))]
                                  options:@{ NSValidatesImmediatelyBindingOption: @YES }];
  [_windowAssociationsController bind:NSContentArrayBinding
                             toObject:self
                          withKeyPath:[NSString stringWithFormat:@"%@.%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(autotype)), NSStringFromSelector(@selector(associations))]
                              options:@{ NSSelectsAllWhenSettingContentBindingOption: @NO }];
  [self.windowTitleComboBox setStringValue:@""];
  [self.windowTitleComboBox bind:NSValueBinding
                        toObject:_windowAssociationsController
                     withKeyPath:[NSString stringWithFormat:@"selection.%@", NSStringFromSelector(@selector(windowTitle))]
                         options:nil];
  
  [self.associationSequenceTextField bind:NSValueBinding
                                 toObject:_windowAssociationsController
                              withKeyPath:[NSString stringWithFormat:@"selection.%@", NSStringFromSelector(@selector(keystrokeSequence))]
                                  options:nil];
  
  
}


#pragma mark -
#pragma mark MPDocument Notifications

- (void)_didAddEntry:(NSNotification *)notification {
  [self.tabView selectTabViewItemAtIndex:MPEntryTabGeneral];
  [self.titleTextField becomeFirstResponder];
}

@end
