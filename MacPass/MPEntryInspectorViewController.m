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

#import "MPDocument.h"
#import "MPIconHelper.h"

#import "Kdb.h"
#import "Kdb3Node.h"
#import "Kdb4Node.h"
#import "KdbEntry+Undo.h"

#import "HNHScrollView.h"
#import "HNHRoundedSecureTextField.h"

typedef NS_ENUM(NSUInteger, MPEntryTab) {
  MPEntryTabGeneral,
  MPEntryTabFiles,
  MPEntryTabCustomFields
};

@interface MPEntryInspectorViewController () {
@private
  NSArrayController *_attachmentsController;
  NSArrayController *_customFieldsController;
  MPAttachmentTableViewDelegate *_attachmentTableDelegate;
  MPCustomFieldTableViewDelegate *_customFieldTableDelegate;
}

@property (nonatomic, assign) BOOL showPassword;
@property (nonatomic, assign) MPEntryTab activeTab;
@property (strong) NSPopover *activePopover;

@property (nonatomic, weak) KdbEntry *entry;

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
      _attachmentTableDelegate = [[MPAttachmentTableViewDelegate alloc] init];
      _customFieldTableDelegate = [[MPCustomFieldTableViewDelegate alloc] init];
      _attachmentTableDelegate.viewController = self;
      _customFieldTableDelegate.viewController = self;
      _activeTab = MPEntryTabGeneral;
    }
    return self;
}

- (void)didLoadView {

  /* ScrollView setup for the General Tab */
  
  HNHScrollView *scrollView = [[HNHScrollView alloc] init];
  scrollView.actAsFlipped = NO;
  scrollView.showBottomShadow = NO;
  [scrollView setHasVerticalScroller:YES];
  [scrollView setDrawsBackground:NO];
  [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
  NSView *clipView = [scrollView contentView];
  
  NSView *tabView = [[self.tabView tabViewItemAtIndex:MPEntryTabGeneral] view];
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
  [[scrollView superview] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
  [clipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_generalView]|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views]];
  [[self view] layoutSubtreeIfNeeded];
  
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
}

- (void)setupBindings:(MPDocument *)document {
  [self bind:@"entry" toObject:document withKeyPath:@"selectedEntry" options:nil];
}

- (void)setEntry:(KdbEntry *)entry {
  if(_entry != entry) {
    _entry = entry;
    [self _updateContent];
  }
}

#pragma mark -
#pragma mark Actions

- (IBAction)addCustomField:(id)sender {
  MPDocument *document = [[self windowController] document];
  [document createStringField:self.entry];
}
- (IBAction)removeCustomField:(id)sender {
  MPDocument *document = [[self windowController] document];
  NSUInteger index = [sender tag];
  Kdb4Entry *entry = (Kdb4Entry *)self.entry;
  [document removeStringField:(entry.stringFields)[index] formEntry:entry];
}

- (IBAction)saveAttachment:(id)sender {
  BOOL isVersion4 = [self.entry isKindOfClass:[Kdb4Entry class]];
  id item = self.entry;
  NSString *fileName = nil;
  if(isVersion4) {
    Kdb4Entry *entry= (Kdb4Entry *)self.entry;
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
        [document addAttachment:attachmentURL toEntry:self.entry];
      }
    }
  }];
}

- (IBAction)removeAttachment:(id)sender {
  MPDocument *document = [[self windowController] document];
  if(document.version == MPDatabaseVersion3) {
    [document removeAttachmentFromEntry:self.entry];
  }
  else if(document.version == MPDatabaseVersion4) {
    Kdb4Entry *entry = (Kdb4Entry *)self.entry;
    BinaryRef *reference = entry.binaries[[sender tag]];
    [document removeAttachment:reference fromEntry:self.entry];
  }
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
      self.entry.passwordUndoable = [controller generatedPassword];
    }
  }
  /* TODO: Check for Icon wizzard */
  
  _activePopover = nil;
}

#pragma mark -
#pragma mark Entry Selection
- (void)_updateContent {
  [self _bindEntry];
  [self _bindAttachments];
  [self _bindCustomFields];
}

- (void)_bindEntry {
  
  if(self.entry) {
    [self.titleTextField bind:NSValueBinding toObject:self.entry withKeyPath:@"titleUndoable" options:nil];
    //[self.itemImageView setImage:[MPIconHelper icon:(MPIconType)self.entry.image ]];
    [self.passwordTextField bind:NSValueBinding toObject:self.entry withKeyPath:@"passwordUndoable" options:nil];
    [self.usernameTextField bind:NSValueBinding toObject:self.entry withKeyPath:@"usernameUndoable" options:nil];
    [self.URLTextField bind:NSValueBinding toObject:self.entry withKeyPath:@"urlUndoable" options:nil];
    [self.notesTextView bind:NSValueBinding toObject:self.entry withKeyPath:@"notesUndoable" options:nil];
    
    BOOL isKdbx = [self.entry isKindOfClass:[Kdb4Entry class]];
    [self.infoTabControl setEnabled:isKdbx forSegment:MPEntryTabCustomFields];
  }
  else {
    [self.titleTextField unbind:NSValueBinding];
    [self.passwordTextField unbind:NSValueBinding];
    [self.usernameTextField unbind:NSValueBinding];
    [self.URLTextField unbind:NSValueBinding];
    [self.notesTextView unbind:NSValueBinding];
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
  if(self.entry && [self.entry isKindOfClass:[Kdb4Entry class]]) {
    [_customFieldsController bind:NSContentArrayBinding toObject:self.entry withKeyPath:@"stringFields" options:nil];
  }
  else if([_customFieldsController content] != nil){
    [_customFieldsController unbind:NSContentArrayBinding];
    [_customFieldsController setContent:nil];
  }
}

@end
