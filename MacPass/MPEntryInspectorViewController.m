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

#import "MPDocument.h"
#import "MPIconHelper.h"

#import "KPKEntry.h"
#import "KPKBinary.h"
#import "KPKAutotype.h"
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
}

@property (nonatomic, assign) BOOL showPassword;
@property (nonatomic, assign) MPEntryTab activeTab;
@property (strong) NSPopover *activePopover;

@property (nonatomic, weak) KPKEntry *entry;

@end

@implementation MPEntryInspectorViewController

- (id)init {
  return  [self initWithNibName:@"EntryInspectorView" bundle:nil];
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
    _attachmentTableDelegate.viewController = self;
    _customFieldTableDelegate.viewController = self;
    _activeTab = MPEntryTabGeneral;
  }
  return self;
}

- (void)didLoadView {
  
  [self _addScrollViewWithView:self.generalView atTab:MPEntryTabGeneral];
  [self _addScrollViewWithView:self.autotypView atTab:MPEntryTabAutotype];
  
  [self.infoTabControl bind:NSSelectedIndexBinding toObject:self withKeyPath:@"activeTab" options:nil];
  [self.tabView bind:NSSelectedIndexBinding toObject:self withKeyPath:@"activeTab" options:nil];
  
  /* Set background to clearcolor so we can draw in the scrollview */
  [self.attachmentTableView setBackgroundColor:[NSColor clearColor]];
  [self.attachmentTableView bind:NSContentBinding toObject:_attachmentsController withKeyPath:@"arrangedObjects" options:nil];
  [self.attachmentTableView setDelegate:_attachmentTableDelegate];
  [self.attachmentTableView setDataSource:_attachmentDataSource];
  [self.attachmentTableView registerForDraggedTypes:@[NSFilenamesPboardType]];
  /* Set background to clearcolor so we can draw in the scrollview */
  [self.customFieldsTableView setBackgroundColor:[NSColor clearColor]];
  [self.customFieldsTableView bind:NSContentBinding toObject:_customFieldsController withKeyPath:@"arrangedObjects" options:nil];
  [self.customFieldsTableView setDelegate:_customFieldTableDelegate];
  
  [self.windowAssociationsTableView setBackgroundColor:[NSColor clearColor]];
  [self.windowAssociationsTableView setDelegate:_windowAssociationsTableDelegate];
  [self.windowAssociationsTableView bind:NSContentBinding toObject:_windowAssociationsController withKeyPath:@"arrangedObjects" options:nil];
  
  [self.passwordTextField bind:@"showPassword" toObject:self withKeyPath:@"showPassword" options:nil];
  [self.togglePassword bind:NSValueBinding toObject:self withKeyPath:@"showPassword" options:nil];
}

- (void)setupBindings:(MPDocument *)document {
  [self bind:@"entry" toObject:document withKeyPath:@"selectedEntry" options:nil];
}

- (void)setEntry:(KPKEntry *)entry {
  if(_entry != entry) {
    _entry = entry;
    [self _updateContent];
  }
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
  KPKBinary *binary = self.entry.binaries[[sender tag]];
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
  KPKBinary *binary = self.entry.binaries[[sender tag]];
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

#pragma mark Editing
- (void)beginEditing {
  [self _toggleEditing:YES];
  
}
- (void)endEditing {
  [self _toggleEditing:NO];
}

#pragma mark -
#pragma mark Popovers

- (IBAction)_popUpPasswordGenerator:(id)sender {
  [self.generatePasswordButton setEnabled:NO];
  [self _showPopopver:[[MPPasswordCreatorViewController alloc] init] atView:self.passwordTextField onEdge:NSMinYEdge];
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
  
  if(self.entry) {
    [self.titleTextField bind:NSValueBinding toObject:self.entry withKeyPath:@"title" options:nil];
    [self.passwordTextField bind:NSValueBinding toObject:self.entry withKeyPath:@"password" options:nil];
    [self.usernameTextField bind:NSValueBinding toObject:self.entry withKeyPath:@"username" options:nil];
    [self.URLTextField bind:NSValueBinding toObject:self.entry withKeyPath:@"url" options:nil];
    [self.notesTextView bind:NSValueBinding toObject:self.entry withKeyPath:@"notes" options:nil];
    [self.expiresCheckButton bind:NSValueBinding toObject:self.entry.timeInfo withKeyPath:@"expires" options:nil];
    [self.tagsTokenField bind:NSValueBinding toObject:self.entry withKeyPath:@"tags" options:nil];
  }
  else {
    [self.titleTextField unbind:NSValueBinding];
    [self.passwordTextField unbind:NSValueBinding];
    [self.usernameTextField unbind:NSValueBinding];
    [self.URLTextField unbind:NSValueBinding];
    [self.notesTextView unbind:NSValueBinding];
    [self.expiresCheckButton unbind:NSValueBinding];
  }
}

- (void)_bindAttachments {
  if(self.entry) {
    [_attachmentsController bind:NSContentArrayBinding toObject:self.entry withKeyPath:@"binaries" options:nil];
  }
  else if([_attachmentsController content] != nil){
    [_attachmentsController unbind:NSContentArrayBinding];
    [_attachmentsController setContent:nil];
  }
}

- (void)_bindCustomFields {
  if(self.entry) {
    [_customFieldsController bind:NSContentArrayBinding toObject:self.entry withKeyPath:@"customAttributes" options:nil];
  }
  else if ([_customFieldsController content] != nil ) {
    [_customFieldsController unbind:NSContentArrayBinding];
    [_customFieldsController setContent:nil];
  }
}

- (void)_bindAutotype {
  if(self.entry) {
    [self.enableAutotypeCheckButton bind:NSValueBinding toObject:self.entry.autotype withKeyPath:@"isEnabled" options:nil];
    [self.customEntrySequenceTextField bind:NSEnabledBinding toObject:self.entry.autotype withKeyPath:@"isEnabled" options:nil];
    [self.customEntrySequenceTextField bind:NSValueBinding toObject:self.entry.autotype withKeyPath:@"defaultSequence" options:nil];
    [_windowAssociationsController bind:NSContentArrayBinding toObject:self.entry.autotype withKeyPath:@"associations" options:nil];
  }
  else {
    [self.enableAutotypeCheckButton unbind:NSValueBinding];
    [self.customEntrySequenceTextField unbind:NSEnabledBinding];
    [self.customEntrySequenceTextField unbind:NSValueBinding];
    if([_windowAssociationsController content] != nil) {
      [_windowAssociationsController unbind:NSContentArrayBinding];
      [_windowAssociationsController setContent:nil];
    }
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
  [_notesTextView setEditable:edit];
  [_notesTextView setSelectable:edit];
  [_modifiedTextField setEditable:edit];
  [_modifiedTextField setSelectable:edit];
  
}

@end
