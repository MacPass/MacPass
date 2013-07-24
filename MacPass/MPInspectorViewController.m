//
//  MPInspectorTabViewController.m
//  MacPass
//
//  Created by Michael Starke on 05.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPInspectorViewController.h"
#import "MPEntryViewController.h"
#import "MPPasswordCreatorViewController.h"
#import "MPShadowBox.h"
#import "MPIconHelper.h"
#import "MPPopupImageView.h"
#import "MPIconSelectViewController.h"
#import "MPDocumentWindowController.h"
#import "MPOutlineViewController.h"
#import "MPDocument.h"
#import "MPCustomFieldView.h"
#import "MPDatabaseVersion.h"
#import "MPCustomFieldTableCellView.h"
#import "MPSelectedAttachmentTableCellView.h"
#import "MPAttachmentTableViewDelegate.h"
#import "MPCustomFieldTableViewDelegate.h"
#import "MPNotifications.h"

#import "NSDate+Humanized.h"

#import "KdbLib.h"
#import "Kdb4Node.h"
#import "Kdb3Node.h"
#import "KdbGroup+Undo.h"
#import "KdbEntry+Undo.h"
#import "StringField+Undo.h"
#import "Kdb4Entry+KVOAdditions.h"
#import "NSMutableData+Base64.h"

#import "HNHGradientView.h"
#import "HNHScrollView.h"
#import "HNHTableRowView.h"
#import "HNHRoundedSecureTextField.h"

enum {
  MPGeneralTab,
  MPAttachmentsTab,
  MPCustomFieldsTab
};

@interface MPInspectorViewController () {
  BOOL _visible;
  NSArrayController *_attachmentsController;
  NSArrayController *_customFieldsController;
  MPAttachmentTableViewDelegate *_attachmentTableDelegate;
  MPCustomFieldTableViewDelegate *_customFieldTableDelegate;
}

@property (weak, nonatomic) KdbEntry *selectedEntry;
@property (weak, nonatomic) KdbGroup *selectedGroup;

@property (strong) NSPopover *activePopover;
@property (weak) IBOutlet NSButton *generatePasswordButton;

@property (nonatomic, strong) NSDate *modificationDate;
@property (nonatomic, strong) NSDate *creationDate;

@property (nonatomic, assign) BOOL showPassword;

@property (nonatomic, assign) NSUInteger activeTab;
@property (weak) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSView *generalView;

- (IBAction)addCustomField:(id)sender;
- (IBAction)removeCustomField:(id)sender;
- (IBAction)saveAttachment:(id)sender;
- (IBAction)addAttachment:(id)sender;
- (IBAction)removeAttachment:(id)sender;
- (IBAction)edit:(id)sender;
- (IBAction)finishEdit:(id)sender;

@end

@implementation MPInspectorViewController

- (id)init {
  return [[MPInspectorViewController alloc] initWithNibName:@"InspectorView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _showPassword = NO;
    _selectedEntry = nil;
    _selectedGroup = nil;
    _attachmentsController = [[NSArrayController alloc] init];
    _customFieldsController = [[NSArrayController alloc] init];
    _attachmentTableDelegate = [[MPAttachmentTableViewDelegate alloc] init];
    _attachmentTableDelegate.viewController = self;
    _customFieldTableDelegate = [[MPCustomFieldTableViewDelegate alloc] init];
    _customFieldTableDelegate.viewController = self;
    _activeTab = MPGeneralTab;
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didLoadView {

  HNHScrollView *scrollView = [[HNHScrollView alloc] init];
  scrollView.actAsFlipped = NO;
  [scrollView setHasVerticalScroller:YES];
  [scrollView setDrawsBackground:NO];
  [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
  NSView *clipView = [scrollView contentView];
  
  NSView *tabView = [[self.tabView tabViewItemAtIndex:MPGeneralTab] view];
  /*
   DO NEVER SET setTranslatesAutoresizingMaskIntoConstraints on NSTabViewItem's view
   [tabView setTranslatesAutoresizingMaskIntoConstraints:NO];
   */
  [scrollView setDocumentView:self.generalView];
  [tabView addSubview:scrollView];
  
  NSDictionary *views = NSDictionaryOfVariableBindings(_generalView, scrollView);
  [[scrollView superview] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views ]];
  [[scrollView superview] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[scrollView]-50-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
  [clipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_generalView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
  [[self view] layoutSubtreeIfNeeded];
  
  
  //[self.scrollContentView setAutoresizingMask:NSViewWidthSizable];
  [[self.itemImageView cell] setBackgroundStyle:NSBackgroundStyleRaised];
  [self.itemImageView setTarget:self];
  [_bottomBar setBorderType:HNHBorderTop];
  
  [_infoTabControl bind:NSSelectedIndexBinding toObject:self withKeyPath:@"activeTab" options:nil];
  [_tabView bind:NSSelectedIndexBinding  toObject:self withKeyPath:@"activeTab" options:nil];
  
  /* Set background to clearcolor so we can draw in the scrollview */
  [_attachmentTableView setBackgroundColor:[NSColor clearColor]];
  [_attachmentTableView bind:NSContentBinding toObject:_attachmentsController withKeyPath:@"arrangedObjects" options:nil];
  [_attachmentTableView setDelegate:_attachmentTableDelegate];
  /* Set background to clearcolor so we can draw in the scrollview */
  [_customFieldsTableView setBackgroundColor:[NSColor clearColor]];
  [_customFieldsTableView bind:NSContentBinding toObject:_customFieldsController withKeyPath:@"arrangedObjects" options:nil];
  [_customFieldsTableView setDelegate:_customFieldTableDelegate];
  
  [self.passwordTextField bind:@"showPassword" toObject:self withKeyPath:@"showPassword" options:nil];
  [self.togglePassword bind:NSValueBinding toObject:self withKeyPath:@"showPassword" options:nil];
  
  [self _clearContent];
}

- (void)setupNotifications:(MPDocumentWindowController *)windowController {
  MPDocument *document = [windowController document];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didChangeCurrentItem:)
                                               name:MPCurrentItemChangedNotification
                                             object:document];
}

- (void)setModificationDate:(NSDate *)modificationDate {
  _modificationDate = modificationDate;
  [self _updateDateStrings];
}

- (void)setCreationDate:(NSDate *)creationDate {
  _creationDate = creationDate;
  [self _updateDateStrings];
}

- (void)_updateDateStrings {
  
  if(!self.creationDate || !self.modificationDate ) {
    [self.modifiedTextField setStringValue:@""];
    [self.createdTextField setStringValue:@""];
    return; // No dates, just clear
  }
  
  NSString *creationString = [self.creationDate humanized];
  NSString *modificationString = [self.modificationDate humanized];

  NSString *modifedAtTemplate = NSLocalizedString(@"MODIFED_AT_%@", @"Modifed at template string. %@ is replaced by locaized date and time");
  NSString *createdAtTemplate = NSLocalizedString(@"CREATED_AT_%@", @"Created at template string. %@ is replaced by locaized date and time");

  [self.modifiedTextField setStringValue:[NSString stringWithFormat:modifedAtTemplate, modificationString]];
  [self.createdTextField setStringValue:[NSString stringWithFormat:createdAtTemplate, creationString]];
  
}

- (void)_updateContent {
  if(self.selectedEntry) {
    [self _showEntry];
  }
  else if(self.selectedGroup) {
    [self _showGroup];
  }
  else {
    [self _clearContent];
  }
  [self _updateAttachments];
  [self _updateCustomFields];
}

- (void)_updateAttachments {
  if(self.selectedEntry) {
    if([self.selectedEntry isKindOfClass:[Kdb4Entry class]]) {
      [_attachmentsController bind:NSContentArrayBinding toObject:self.selectedEntry withKeyPath:@"binaries" options:nil];
    }
    else {
      [_attachmentsController bind:NSContentArrayBinding toObject:self.selectedEntry withKeyPath:@"binaries" options:nil];
    }
  }
  else if([_attachmentsController content] != nil){
    [_attachmentsController unbind:NSContentArrayBinding];
    [_attachmentsController setContent:nil];
    
  }
}

- (void)_updateCustomFields {
  if(self.selectedEntry && [self.selectedEntry isKindOfClass:[Kdb4Entry class]]) {
    [_customFieldsController bind:NSContentArrayBinding toObject:self.selectedEntry withKeyPath:@"stringFields" options:nil];
  }
  else if([_customFieldsController content] != nil){
    [_customFieldsController unbind:NSContentArrayBinding];
    [_customFieldsController setContent:nil];
  }
}

- (void)_showEntry {
  
  [self bind:@"modificationDate" toObject:self.selectedEntry withKeyPath:@"lastModificationTime" options:nil];
  [self bind:@"creationDate" toObject:self.selectedEntry withKeyPath:@"creationTime" options:nil];
  
  [self.itemNameTextfield bind:NSValueBinding toObject:self.selectedEntry withKeyPath:MPEntryTitleUndoableKey options:nil];
  [self.itemImageView setImage:[MPIconHelper icon:(MPIconType)self.selectedEntry.image ]];
  [self.passwordTextField bind:NSValueBinding toObject:self.selectedEntry withKeyPath:MPEntryPasswordUndoableKey options:nil];
  [self.usernameTextField bind:NSValueBinding toObject:self.selectedEntry withKeyPath:MPEntryUsernameUndoableKey options:nil];
  [self.titleOrNameLabel setStringValue:NSLocalizedString(@"TITLE",@"")];
  [self.titleTextField bind:NSValueBinding toObject:self.selectedEntry withKeyPath:MPEntryTitleUndoableKey options:nil];
  [self.URLTextField bind:NSValueBinding toObject:self.selectedEntry withKeyPath:MPEntryUrlUndoableKey options:nil];
  [self.notesTextView bind:NSValueBinding toObject:self.selectedEntry withKeyPath:MPEntryNotesUndoableKey options:nil];
  
  [self _setInputEnabled:YES];
}

- (void)_showGroup {
  
  [self bind:@"modificationDate" toObject:self.selectedGroup withKeyPath:@"lastModificationTime" options:nil];
  [self bind:@"creationDate" toObject:self.selectedGroup withKeyPath:@"creationTime" options:nil];
  
  [self.itemNameTextfield bind:NSValueBinding toObject:self.selectedGroup withKeyPath:MPGroupNameUndoableKey options:nil];
  [self.itemImageView setImage:[MPIconHelper icon:(MPIconType)self.selectedGroup.image ]];
  [self.titleOrNameLabel setStringValue:NSLocalizedString(@"NAME",@"")];
  [self.titleTextField bind:NSValueBinding toObject:self.selectedGroup withKeyPath:MPGroupNameUndoableKey options:nil];
  
  // Clear other bindins
  [self.passwordTextField unbind:NSValueBinding];
  [self.usernameTextField unbind:NSValueBinding];
  [self.URLTextField unbind:NSValueBinding];
  
  // Reset Fields
  [self.passwordTextField setStringValue:@""];
  [self.usernameTextField setStringValue:@""];
  [self.URLTextField setStringValue:@""];
  
  // Reste toggle. Do not call setter on control or the bindings wont update
  self.activeTab = MPGeneralTab;
  [self _setInputEnabled:YES];
}

- (void)_clearContent {
  
  [self _setInputEnabled:NO];
  
  [self.itemNameTextfield unbind:NSValueBinding];
  [self.passwordTextField unbind:NSValueBinding];
  [self.usernameTextField unbind:NSValueBinding];
  [self.titleTextField unbind:NSValueBinding];
  [self.URLTextField unbind:NSValueBinding];
  [self.notesTextView unbind:NSValueBinding];
  
  [self.itemNameTextfield setStringValue:NSLocalizedString(@"INSPECTOR_NO_SELECTION", @"No item selected in inspector")];
  [self.itemImageView setImage:[NSImage imageNamed:NSImageNameActionTemplate]];
  
  [self.itemNameTextfield setStringValue:@""];
  [self.passwordTextField setStringValue:@""];
  [self.usernameTextField setStringValue:@""];
  [self.titleTextField setStringValue:@""];
  [self.URLTextField setStringValue:@""];
  [self.notesTextView setString:@""];
  
  [self.createdTextField setStringValue:@""];
  [self.modifiedTextField setStringValue:@""];
  
}

- (void)_setInputEnabled:(BOOL)enabled {
  
  [self.itemImageView setAction: enabled ? @selector(_showImagePopup:) : NULL ];
  [self.itemImageView setEnabled:enabled];
  [self.itemNameTextfield setTextColor: enabled ? [NSColor controlTextColor] : [NSColor disabledControlTextColor] ];
  [self.itemNameTextfield setEnabled:enabled];
  [self.titleTextField setEnabled:enabled];
  [self.infoTabControl setEnabled:enabled forSegment:MPGeneralTab];
  
  
  enabled &= (self.selectedEntry != nil);
  [self.passwordTextField setEnabled:enabled];
  [self.togglePassword setEnabled:enabled];
  [self.usernameTextField setEnabled:enabled];
  [self.URLTextField setEnabled:enabled];
  [self.generatePasswordButton setEnabled:enabled];
  
  [self.infoTabControl setEnabled:enabled forSegment:MPAttachmentsTab];
  
  enabled &= [self.selectedEntry isKindOfClass:[Kdb4Entry class]];
  [self.infoTabControl setEnabled:enabled forSegment:MPCustomFieldsTab];
}

#pragma mark Popovers
- (void)_showImagePopup:(id)sender {
  [self _showPopopver:[[MPIconSelectViewController alloc] init]  atView:self.itemImageView onEdge:NSMinYEdge];
}

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
      [self.selectedEntry setPasswordUndoable:[controller generatedPassword]];
    }
  }
  /* TODO: Check for Icon wizzard */
  
  _activePopover = nil;
}

#pragma mark Actions
- (IBAction)addCustomField:(id)sender {
  MPDocument *document = [[self windowController] document];
  [document createStringField:self.selectedEntry];
}
- (IBAction)removeCustomField:(id)sender {
  MPDocument *document = [[self windowController] document];
  NSUInteger index = [sender tag];
  Kdb4Entry *entry = (Kdb4Entry *)self.selectedEntry;
  [document removeStringField:(entry.stringFields)[index] formEntry:entry];
}

- (IBAction)saveAttachment:(id)sender {
  BOOL isVersion4 = [self.selectedEntry isKindOfClass:[Kdb4Entry class]];
  id item = self.selectedEntry;
  NSString *fileName = nil;
  if(isVersion4) {
    Kdb4Entry *entry= (Kdb4Entry *)self.selectedEntry;
    item = entry.binaries[[sender tag]];
    fileName = ((BinaryRef *)item).key;
  }
  else {
    fileName = ((Kdb3Entry *)item).binaryDesc;
  }
  
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  [savePanel setCanCreateDirectories:YES];
  [savePanel setNameFieldStringValue:fileName];
  
  [savePanel beginSheetModalForWindow:[[self windowController] window] completionHandler:^(NSInteger result) {
    if(result == NSFileHandlingPanelOKButton) {
      MPDocument *document = [[self windowController] document];
      [document saveAttachmentForItem:item toLocation:[savePanel URL]];
    }
  }];
}

- (IBAction)addAttachment:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setCanChooseFiles:YES];
  [openPanel setAllowsMultipleSelection:YES];
  [openPanel beginSheetModalForWindow:[[self windowController] window] completionHandler:^(NSInteger result) {
    if(result == NSFileHandlingPanelOKButton) {
      MPDocument *document = [[self windowController] document];
      for (NSURL *attachmentURL in [openPanel URLs]) {
        [document addAttachment:attachmentURL toEntry:self.selectedEntry];
      }
    }
  }];
}

- (IBAction)removeAttachment:(id)sender {
  MPDocument *document = [[self windowController] document];
  if(document.version == MPDatabaseVersion3) {
    [document removeAttachmentFromEntry:self.selectedEntry];
  }
  else if(document.version == MPDatabaseVersion4) {
    Kdb4Entry *entry = (Kdb4Entry *)self.selectedEntry;
    BinaryRef *reference = entry.binaries[[sender tag]];
    [document removeAttachment:reference fromEntry:self.selectedEntry];
  }
}

- (IBAction)edit:(id)sender {
  [self.titleTextField setEditable:YES];
  [self.usernameTextField setEditable:YES];
  [[[[self windowController] document] undoManager] beginUndoGrouping];
}

- (IBAction)finishEdit:(id)sender {
  NSUndoManager *undoManger =   [[[self windowController] document] undoManager];
  if([undoManger canUndo]) {
    [undoManger setActionName:@"Edit"];
  }
  [undoManger endUndoGrouping];
  [self.titleTextField setEditable:NO];
  [self.titleTextField setSelectable:YES];
  [self.usernameTextField setEditable:NO];
  [self.usernameTextField setSelectable:YES];

}

#pragma mark Notificiations
- (void)_didChangeCurrentItem:(NSNotification *)notification {
  /**
   Remove double handling.
   Just call for documents properties when neede
   */
  MPDocument *document = [[self windowController] document];
  if(!document.selectedItem) {
    self.selectedGroup = nil;
    self.selectedEntry = nil;
  }
  BOOL isGroup = document.selectedItem == document.selectedGroup;
  BOOL isEntry = document.selectedItem == document.selectedEntry;
  if(isGroup) {
    self.selectedEntry = nil;
    self.selectedGroup = document.selectedItem;
  }
  else if(isEntry) {
    self.selectedGroup = nil;
    self.selectedEntry = document.selectedItem;
  }
  [self _updateContent];
}

@end
