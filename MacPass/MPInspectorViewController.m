//
//  MPInspectorTabViewController.m
//  MacPass
//
//  Created by Michael Starke on 05.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPInspectorViewController.h"
#import "MPEntryViewController.h"
#import "MPOutlineViewDelegate.h"
#import "MPPasswordCreatorViewController.h"
#import "MPShadowBox.h"
#import "MPIconHelper.h"
#import "MPPopupImageView.h"
#import "MPIconSelectViewController.h"
#import "MPDocumentWindowController.h"
#import "MPOutlineViewController.h"
#import "MPOutlineViewDelegate.h"
#import "MPDocument.h"

#import "KdbLib.h"
#import "Kdb4Node.h"
#import "Kdb3Node.h"
#import "KdbGroup+Undo.h"
#import "KdbEntry+Undo.h"

#import "HNHGradientView.h"

enum {
  MPGeneralTab,
  MPAdvancedTab
};

@interface MPInspectorViewController () {
  BOOL _visible;
}

@property (assign, nonatomic) KdbEntry *selectedEntry;
@property (assign, nonatomic) KdbGroup *selectedGroup;

@property (retain) NSPopover *activePopover;
@property (assign) IBOutlet NSButton *generatePasswordButton;

@property (nonatomic, assign) NSDate *modificationDate;
@property (nonatomic, assign) NSDate *creationDate;

@property (assign) NSUInteger activeTab;
@property (assign) IBOutlet NSTabView *tabView;
@property (retain) NSArrayController *attachmentsController;

@end

@implementation MPInspectorViewController

- (id)init {
  return [[MPInspectorViewController alloc] initWithNibName:@"InspectorView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _selectedEntry = nil;
    _selectedGroup = nil;
    _attachmentsController = [[NSArrayController alloc] init];
    _activeTab = MPGeneralTab;
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_activePopover release];
  [super dealloc];
}

- (void)didLoadView {
  [self.scrollContentView setAutoresizingMask:NSViewWidthSizable];
  [[self.itemImageView cell] setBackgroundStyle:NSBackgroundStyleRaised];
  [self.itemImageView setTarget:self];
  [_bottomBar setBorderType:HNHBorderTop];
  
  //[[_infoTabControl cell] setTag:MPAdvancedTab forSegment:MPAdvancedTab];
  //[[_infoTabControl cell] setTag:MPGeneralTab forSegment:MPGeneralTab];
  
  [_infoTabControl bind:NSSelectedIndexBinding toObject:self withKeyPath:@"activeTab" options:nil];
  [_tabView bind:NSSelectedIndexBinding  toObject:self withKeyPath:@"activeTab" options:nil];
  
  [_attachmentTableView bind:NSContentBinding toObject:self.attachmentsController withKeyPath:@"arrangedObjects" options:nil];
  [_attachmentTableView setDelegate:self];
  
  [self _clearContent];
}

- (void)setupNotifications:(MPDocumentWindowController *)windowController {
  /* Register for Entry selection */
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didChangeCurrentItem:)
                                               name:MPCurrentItemChangedNotification
                                             object:windowController];
}

- (void)_updateInfoString {
  NSDate *modificationDate;
  NSDate *creationDate;
  if(self.selectedEntry) {
    modificationDate = self.selectedEntry.lastModificationTime;
    creationDate = self.selectedEntry.creationTime;
  }
  else {
    modificationDate = self.selectedGroup.lastModificationTime;
    creationDate = self.selectedGroup.creationTime;
  }
  [self.infoTextField setStringValue:[NSString stringWithFormat:@"created: %@ modified: %@", creationDate, modificationDate]];
}

- (void)setModificationDate:(NSDate *)modificationDate {
  [self _updateInfoString];
}

- (void)setCreationDate:(NSDate *)creationDate {
  [self _updateInfoString];
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
}

- (void)_updateAttachments {
  if(self.selectedEntry) {
    if([self.selectedEntry isKindOfClass:[Kdb4Entry class]]) {
      [self.attachmentsController bind:NSContentArrayBinding toObject:self.selectedEntry withKeyPath:@"binaries" options:nil];
    }
    else {
      /* Use binarydes and binary form Kdb3Entry */
    }
  }
  else if([self.attachmentsController content] != nil){
    
    [self.attachmentsController unbind:NSContentArrayBinding];
    [self.attachmentsController setContent:nil];
    
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
  
  // Reste toggle
  [self.infoTabControl setSelected:YES forSegment:MPGeneralTab];
  [self.infoTabControl setSelected:NO forSegment:MPAdvancedTab];
  
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
  
}

- (void)_setInputEnabled:(BOOL)enabled {
  
  [self.itemImageView setAction: enabled ? @selector(_showImagePopup:) : NULL ];
  [self.itemImageView setEnabled:enabled];
  [self.itemNameTextfield setTextColor: enabled ? [NSColor controlTextColor] : [NSColor disabledControlTextColor] ];
  [self.itemNameTextfield setEnabled:enabled];
  [self.titleTextField setEnabled:enabled];
  
  enabled &= (self.selectedEntry != nil);
  [self.passwordTextField setEnabled:enabled];
  [self.usernameTextField setEnabled:enabled];
  [self.URLTextField setEnabled:enabled];
  [self.generatePasswordButton setEnabled:enabled];
  //[self.infoTabControl setEnabled:enabled forSegment:MPGeneralTab];
  //[self.infoTabControl setEnabled:enabled forSegment:MPAdvancedTab];
}

#pragma mark Popovers
- (void)_showImagePopup:(id)sender {
  [self _showPopopver:[[[MPIconSelectViewController alloc] init] autorelease]  atView:self.itemImageView onEdge:NSMinYEdge];
}

- (IBAction)_popUpPasswordGenerator:(id)sender {
  [self.generatePasswordButton setEnabled:NO];
  [self _showPopopver:[[[MPPasswordCreatorViewController alloc] init] autorelease] atView:self.passwordTextField onEdge:NSMinYEdge];
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
  if([controller respondsToSelector:@selector(generatedPassword)]) {
    NSString *password = [controller generatedPassword];
    /* We should only use the password if there is actally one */
    if([password length] > 0) {
      [self.selectedEntry setPasswordUndoable:[controller generatedPassword]];
    }
  }
  [_activePopover release];
  _activePopover = nil;
}

#pragma mark Notificiations
- (void)_didChangeCurrentItem:(NSNotification *)notification {
  MPDocumentWindowController *sender = [notification object];
  id item = sender.currentItem;
  if(!item) {
    self.selectedGroup = nil;
    self.selectedEntry = nil;
  }
  if([item isKindOfClass:[KdbGroup class]]) {
    self.selectedEntry = nil;
    self.selectedGroup = sender.currentItem;
  }
  else if([item isKindOfClass:[KdbEntry class]]) {
    self.selectedGroup = nil;
    self.selectedEntry = sender.currentItem;
  }
  [self _updateContent];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  NSTableCellView *view = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:tableView];
  if([self.selectedEntry isKindOfClass:[Kdb4Entry class]]) {
    Kdb4Entry *entry = (Kdb4Entry *)self.selectedEntry;
    BinaryRef *binaryRef = entry.binaries[row];
    [[view textField] bind:NSValueBinding toObject:binaryRef withKeyPath:@"key" options:nil];
    MPDocument *document = [[self windowController] document];
    Kdb4Tree *tree = (Kdb4Tree *)document.tree;
    NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
      Binary *binaryFile = evaluatedObject;
      return (binaryFile.binaryId == binaryRef.ref);
    }];
    NSArray *filteredBinary = [tree.binaries filteredArrayUsingPredicate:filterPredicate];
    Binary *attachedFile = [filteredBinary lastObject];
  }
  return view;
}

@end
