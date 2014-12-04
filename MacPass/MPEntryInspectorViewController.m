//
//  MPEntryInspectorViewController.m
//  MacPass
//
//  Created by Michael Starke on 27.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPEntryInspectorViewController.h"
#import "MPAttachmentTableViewDelegate.h"
#import "MPCustomFieldTableViewDelegate.h"
#import "MPPasswordCreatorViewController.h"
#import "MPAttachmentTableDataSource.h"
#import "MPWindowAssociationsTableViewDelegate.h"
#import "MPWindowTitleComboBoxDelegate.h"

#import "NSString+MPPasswordCreation.h"

#import "MPDocument.h"
#import "MPIconHelper.h"
#import "MPValueTransformerHelper.h"
#import "MPTemporaryFileStorage.h"
#import "MPTemporaryFileStorageCenter.h"
#import "MPActionHelper.h"
#import "MPSettingsHelper.h"

#import "KPKEntry.h"
#import "KPKBinary.h"
#import "KPKAutotype.h"
#import "KPKTimeInfo.h"
#import "KPKWindowAssociation.h"

#import "HNHScrollView.h"
#import "HNHRoundedSecureTextField.h"

typedef NS_ENUM(NSUInteger, MPEntryTab) {
  MPEntryTabGeneral,
  MPEntryTabFiles,
  MPEntryTabCustomFields,
  MPEntryTabAutotype
};

@interface MPEntryInspectorViewController () {
@private
  NSArrayController *_attachmentsController;
  NSArrayController *_customFieldsController;
  NSArrayController *_windowAssociationsController;
  MPAttachmentTableViewDelegate *_attachmentTableDelegate;
  MPCustomFieldTableViewDelegate *_customFieldTableDelegate;
  MPAttachmentTableDataSource *_attachmentDataSource;
  MPWindowAssociationsTableViewDelegate *_windowAssociationsTableDelegate;
  MPWindowTitleComboBoxDelegate *_windowTitleMenuDelegate;
}

@property (nonatomic, assign) BOOL showPassword;
@property (nonatomic, assign) MPEntryTab activeTab;
@property (strong) NSPopover *activePopover;

@property (nonatomic, weak) KPKEntry *entry;
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
    _windowAssociationsController = [[NSArrayController alloc] init];
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

- (void)didLoadView {
  
  [self _addScrollViewWithView:self.generalView atTab:MPEntryTabGeneral];
  [self _addScrollViewWithView:self.autotypView atTab:MPEntryTabAutotype];
  
  [self.infoTabControl bind:NSSelectedIndexBinding toObject:self withKeyPath:NSStringFromSelector(@selector(activeTab)) options:nil];
  [self.tabView bind:NSSelectedIndexBinding toObject:self withKeyPath:NSStringFromSelector(@selector(activeTab)) options:nil];
  
  /* Set background to clearcolor so we can draw in the scrollview */
  self.attachmentTableView.backgroundColor = [NSColor clearColor];
  [self.attachmentTableView bind:NSContentBinding toObject:_attachmentsController withKeyPath:NSStringFromSelector(@selector(arrangedObjects)) options:nil];
  self.attachmentTableView.delegate = _attachmentTableDelegate;
  self.attachmentTableView.dataSource = _attachmentDataSource;
  [self.attachmentTableView registerForDraggedTypes:@[NSFilenamesPboardType]];
  /* Set background to clearcolor so we can draw in the scrollview */
  self.customFieldsTableView.backgroundColor = [NSColor clearColor];
  [self.customFieldsTableView bind:NSContentBinding toObject:_customFieldsController withKeyPath:NSStringFromSelector(@selector(arrangedObjects)) options:nil];
  self.customFieldsTableView.delegate = _customFieldTableDelegate;
  
  self.windowAssociationsTableView.backgroundColor = [NSColor clearColor];
  self.windowAssociationsTableView.delegate = _windowAssociationsTableDelegate;
  [self.windowAssociationsTableView bind:NSContentBinding toObject:_windowAssociationsController withKeyPath:NSStringFromSelector(@selector(arrangedObjects)) options:nil];
  [self.windowAssociationsTableView bind:NSSelectionIndexesBinding toObject:_windowAssociationsController withKeyPath:NSSelectionIndexesBinding options:nil];

  self.windowTitleComboBox.delegate = _windowTitleMenuDelegate;
  
  [self.passwordTextField bind:NSStringFromSelector(@selector(showPassword)) toObject:self withKeyPath:NSStringFromSelector(@selector(showPassword)) options:nil];
  [self.togglePassword bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(showPassword)) options:nil];
}

- (void)setupBindings:(MPDocument *)document {
  [self bind:NSStringFromSelector(@selector(entry)) toObject:document withKeyPath:NSStringFromSelector(@selector(selectedEntry)) options:nil];
}

- (void)setEntry:(KPKEntry *)entry {
  if(_entry != entry) {
    _entry = entry;
    [self _updateContent];
  }
}

- (void)regsiterNotificationsForDocument:(MPDocument *)document {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didAddEntry:)
                                               name:MPDocumentDidAddEntryNotification
                                             object:document];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_willSave:)
                                               name:MPDocumentWillSaveNotification
                                             object:document];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Actions

- (void)addCustomField:(id)sender {
  MPDocument *document = [[self windowController] document];
  [document createCustomAttribute:self.entry];
}
- (void)removeCustomField:(id)sender {
  NSUInteger index = [sender tag];
  KPKAttribute *attribute = self.entry.customAttributes[index];
  [self.entry removeCustomAttribute:attribute];
}

- (void)saveAttachment:(id)sender {
  NSInteger row = [self.attachmentTableView selectedRow];
  if(row < 0) {
    return; // No selection
  }
  KPKBinary *binary = self.entry.binaries[row];
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  [savePanel setCanCreateDirectories:YES];
  [savePanel setNameFieldStringValue:binary.name];
  
  [savePanel beginSheetModalForWindow:[[self windowController] window] completionHandler:^(NSInteger result) {
    if(result == NSFileHandlingPanelOKButton) {
      [binary saveToLocation:[savePanel URL]];
    }
  }];
}

- (void)addAttachment:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setCanChooseFiles:YES];
  [openPanel setAllowsMultipleSelection:YES];
  [openPanel beginSheetModalForWindow:[[self windowController] window] completionHandler:^(NSInteger result) {
    if(result == NSFileHandlingPanelOKButton) {
      for (NSURL *attachmentURL in [openPanel URLs]) {
        KPKBinary *binary = [[KPKBinary alloc] initWithContentsOfURL:attachmentURL];
        [self.entry addBinary:binary];
      }
    }
  }];
}

- (void)removeAttachment:(id)sender {
  NSInteger row = [self.attachmentTableView selectedRow];
  if(row < 0) {
    return; // no selection
  }
  KPKBinary *binary = self.entry.binaries[row];
  [self.entry removeBinary:binary];
}

- (void)addWindowAssociation:(id)sender {
  KPKWindowAssociation *associtation = [[KPKWindowAssociation alloc] initWithWindow:NSLocalizedString(@"DEFAULT_WINDOW_TITLE", "") keystrokeSequence:nil];
  [self.entry.autotype addAssociation:associtation];
}

- (void)removeWindowAssociation:(id)sender {
  NSInteger row = [self.windowAssociationsTableView selectedRow];
  if(row > - 1 && row < [self.entry.autotype.associations count]) {
    [self.entry.autotype removeAssociation:self.entry.autotype.associations[row]];
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

- (void)beginEditing {
  [self _toggleEditing:YES];
  
}
- (void)endEditing {
  [self _toggleEditing:NO];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  switch([MPActionHelper typeForAction:[menuItem action]]) {
    case MPActionToggleQuicklook: {
      BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyEnableQuicklookPreview];
      return enabled ? [self acceptsPreviewPanelControl:nil] : NO;
    }
    default:
      return YES;
  }
}

#pragma mark -
#pragma mark QLPreviewPanelDelegate

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel {
  if(self.activeTab == MPEntryTabFiles) {
    return ([self.attachmentTableView selectedRow] != -1);
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
  KPKBinary *binary = self.entry.binaries[row];
  MPTemporaryFileStorage *oldStorage = (MPTemporaryFileStorage *)panel.dataSource;
  [[MPTemporaryFileStorageCenter defaultCenter] unregisterStorage:oldStorage];
  panel.dataSource = [[MPTemporaryFileStorageCenter defaultCenter] storageForBinary:binary];
}

#pragma mark -
#pragma mark Popovers

- (IBAction)_popUpPasswordGenerator:(id)sender {
  [self.generatePasswordButton setEnabled:NO];
  MPPasswordCreatorViewController *viewController = [[MPPasswordCreatorViewController alloc] init];
  viewController.allowsEntryDefaults = YES;
  viewController.entry = self.entry;
  [self _showPopopver:viewController atView:self.passwordTextField onEdge:NSMinYEdge];
}

- (void)_showPopopver:(NSViewController *)viewController atView:(NSView *)view onEdge:(NSRectEdge)edge {
  if(_activePopover.contentViewController == viewController) {
    return; // Do nothing, we already did show the controller
  }
  [_activePopover close];
  NSAssert(_activePopover == nil, @"Popover hast to be niled out");
  _activePopover = [[NSPopover alloc] init];
  _activePopover.delegate = self;
  _activePopover.behavior = NSPopoverBehaviorTransient;
  if([viewController respondsToSelector:@selector(setCloseTarget:)]) {
    [(id)viewController setCloseTarget:_activePopover];
  }
  _activePopover.contentViewController = viewController;
  
  [_activePopover showRelativeToRect:NSZeroRect ofView:view preferredEdge:edge];
}

- (void)popoverDidClose:(NSNotification *)notification {
  /* We do not enable the button all the time, but it's wokring find this way */
  [self.generatePasswordButton setEnabled:YES];
  id controller = _activePopover.contentViewController;
  /* Check for password wizzard */
  if([controller respondsToSelector:@selector(generatedPassword)]) {
    NSString *password = [controller generatedPassword];
    /* We should only use the password if there is actally one */
    if([password length] > 0) {
      self.entry.password = [controller generatedPassword];
    }
  }
  /* TODO: Check for Icon wizzard */
  
  _activePopover = nil;
}

#pragma mark -
#pragma mark UI Setup
- (void)_addScrollViewWithView:(NSView *)view atTab:(MPEntryTab)tab {
  /* ScrollView setup for the General Tab */
  
  HNHScrollView *scrollView = [[HNHScrollView alloc] init];
  scrollView.actAsFlipped = NO;
  scrollView.showBottomShadow = NO;
  [scrollView setHasVerticalScroller:YES];
  [scrollView setDrawsBackground:NO];
  [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
  NSView *clipView = [scrollView contentView];
  
  NSTabViewItem *tabViewItem = [self.tabView tabViewItemAtIndex:tab];
  NSView *tabView = [tabViewItem view];
  /*
   DO NEVER SET setTranslatesAutoresizingMaskIntoConstraints on NSTabViewItem's view
   [tabView setTranslatesAutoresizingMaskIntoConstraints:NO];
   */
  [scrollView setDocumentView:view];
  [tabView addSubview:scrollView];
  [tabViewItem setInitialFirstResponder:scrollView];
  
  NSDictionary *views = NSDictionaryOfVariableBindings(view, scrollView);
  [[scrollView superview] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views ]];
  [[scrollView superview] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
  [clipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views]];
  [[self view] layoutSubtreeIfNeeded];
}

#pragma mark -
#pragma mark Entry Selection
- (void)_updateContent {
  [self _bindEntry];
  [self _bindAttachments];
  [self _bindCustomFields];
  [self _bindAutotype];
}

- (void)_bindEntry {
  static NSArray *items;
  if(!items) {
    items = @[ self.titleTextField,
               self.passwordTextField,
               self.usernameTextField,
               self.URLTextField,
               self.expiresCheckButton,
               self.tagsTokenField ];
  }
  if(self.entry) {
    [self.titleTextField bind:NSValueBinding toObject:self.entry withKeyPath:NSStringFromSelector(@selector(title)) options:nil];
    [self.passwordTextField bind:NSValueBinding toObject:self.entry withKeyPath:NSStringFromSelector(@selector(password)) options:nil];
    [self.usernameTextField bind:NSValueBinding toObject:self.entry withKeyPath:NSStringFromSelector(@selector(username)) options:nil];
    [self.URLTextField bind:NSValueBinding toObject:self.entry withKeyPath:NSStringFromSelector(@selector(url)) options:nil];
    [self.expiresCheckButton bind:NSTitleBinding
                         toObject:self.entry.timeInfo
                      withKeyPath:NSStringFromSelector(@selector(expiryTime))
                          options:@{ NSValueTransformerNameBindingOption:MPExpiryDateValueTransformer }];
    [self.expiresCheckButton bind:NSValueBinding toObject:self.entry.timeInfo withKeyPath:NSStringFromSelector(@selector(expires)) options:nil];
    [self.tagsTokenField bind:NSValueBinding toObject:self.entry withKeyPath:NSStringFromSelector(@selector(tags)) options:nil];
    [self.uuidTextField bind:NSValueBinding toObject:self.entry.uuid withKeyPath:NSStringFromSelector(@selector(UUIDString)) options:nil];
    self.uuidTextField.editable = NO;
    
    /* Setup enable/disable */
    for(id item in items) {
      [item bind:NSEnabledBinding toObject:self.entry withKeyPath:NSStringFromSelector(@selector(isEditable)) options:nil];
    }
  }
  else {
    for(id item in items) {
      [item unbind:NSValueBinding];
      [item unbind:NSEnabledBinding];
    }
    [self.uuidTextField unbind:NSValueBinding];
    [self.expiresCheckButton unbind:NSTitleBinding];
  }
}

- (void)_bindAttachments {
  if(self.entry) {
    [_attachmentsController bind:NSContentArrayBinding toObject:self.entry withKeyPath:NSStringFromSelector(@selector(binaries)) options:nil];
  }
  else if([_attachmentsController content] != nil){
    [_attachmentsController unbind:NSContentArrayBinding];
    [_attachmentsController setContent:nil];
  }
}

- (void)_bindCustomFields {
  if(self.entry) {
    [_customFieldsController bind:NSContentArrayBinding toObject:self.entry withKeyPath:NSStringFromSelector(@selector(customAttributes)) options:nil];
  }
  else if ([_customFieldsController content] != nil ) {
    [_customFieldsController unbind:NSContentArrayBinding];
    [_customFieldsController setContent:nil];
  }
}

- (void)_bindAutotype {
  if(self.entry) {
    [self.enableAutotypeCheckButton bind:NSValueBinding toObject:self.entry.autotype withKeyPath:NSStringFromSelector(@selector(isEnabled)) options:nil];
    [self.obfuscateAutotypeCheckButton bind:NSValueBinding toObject:self.entry.autotype withKeyPath:NSStringFromSelector(@selector(obfuscateDataTransfer)) options:nil];
    [self.customEntrySequenceTextField bind:NSEnabledBinding toObject:self.entry.autotype withKeyPath:NSStringFromSelector(@selector(isEnabled)) options:nil];
    [self.customEntrySequenceTextField bind:NSValueBinding toObject:self.entry.autotype withKeyPath:NSStringFromSelector(@selector(defaultKeystrokeSequence)) options:@{ NSValidatesImmediatelyBindingOption: @(YES) }];
    [_windowAssociationsController bind:NSContentArrayBinding toObject:self.entry.autotype withKeyPath:NSStringFromSelector(@selector(associations)) options:nil];
    //[self.windowTitleComboBox setStringValue:@""];
    NSString *selectedWindowTitlePath = [[NSString alloc] initWithFormat:@"selection.%@", NSStringFromSelector(@selector(windowTitle))];
    [self.windowTitleComboBox bind:NSValueBinding toObject:_windowAssociationsController withKeyPath:selectedWindowTitlePath options:nil];
    
    NSString *selectedWindowKeyStrokesPath = [[NSString alloc] initWithFormat:@"selection.%@", NSStringFromSelector(@selector(keystrokeSequence))];
    [self.associationSequenceTextField bind:NSValueBinding toObject:_windowAssociationsController withKeyPath:selectedWindowKeyStrokesPath options:nil];
  }
  else {
    [self.enableAutotypeCheckButton unbind:NSValueBinding];
    [self.customEntrySequenceTextField unbind:NSEnabledBinding];
    [self.customEntrySequenceTextField unbind:NSValueBinding];
    if([_windowAssociationsController content] != nil) {
      [_windowAssociationsController unbind:NSContentArrayBinding];
      [_windowAssociationsController setContent:nil];
    }
    [self.windowTitleComboBox unbind:NSValueBinding];
    [self.associationSequenceTextField unbind:NSValueBinding];
  }
}

- (void)_toggleEditing:(BOOL)edit {
  /* TODO: not fully working right now */
  
  [_titleTextField setEditable:edit];
  [_titleTextField setSelectable:edit];
  [_usernameTextField setEditable:edit];
  [_usernameTextField setSelectable:edit];
  [_URLTextField setEditable:edit];
  [_URLTextField setSelectable:edit];
  [_passwordTextField setEditable:edit];
  [_passwordTextField setSelectable:edit];
  
  [_createdTextField setEditable:edit];
  [_createdTextField setSelectable:edit];
  [_modifiedTextField setEditable:edit];
  [_modifiedTextField setSelectable:edit];
  
}

#pragma mark -
#pragma mark MPDocument Notifications

- (void)_didAddEntry:(NSNotification *)notification {
  [self.tabView selectTabViewItemAtIndex:MPEntryTabGeneral];
  [self.titleTextField becomeFirstResponder];
}

- (void)_willSave:(NSNotification *)notification {
  // Force selected textfield to end editing
  [[[self view] window] makeFirstResponder:nil];
}

@end
