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
#import "KdbLib.h"
#import "Kdb4Node.h"
#import "KdbGroup+Undo.h"
#import "KdbEntry+Undo.h"
#import "HNHGradientView.h"

@interface MPInspectorViewController () {
  BOOL _visible;
}

@property (assign, nonatomic) KdbEntry *selectedEntry;
@property (assign, nonatomic) KdbGroup *selectedGroup;

@property (assign, nonatomic) BOOL showsEntry;
@property (retain) NSPopover *activePopover;
@property (assign) IBOutlet NSButton *generatePasswordButton;
@property (nonatomic, assign) NSDate *modificationDate;
@property (nonatomic, assign) NSDate *creationDate;
@property (retain, nonatomic) NSArrayController *attachmentController;

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
    _showsEntry = NO;
    _attachmentController = [[NSArrayController alloc] init];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_attachmentController release];
  [_activePopover release];
  [super dealloc];
}

- (void)didLoadView {
  [[self.itemImageView cell] setBackgroundStyle:NSBackgroundStyleRaised];
  [self.itemImageView setTarget:self];
  [_bottomBar setBorderType:HNHBorderTop];
  [[_infoTextField cell] setBackgroundStyle:NSBackgroundStyleRaised];
  [_attachmentTableView setDelegate:self];
  [_attachmentTableView bind:NSContentBinding toObject:_attachmentController withKeyPath:@"arrangedObjects" options:nil];
  [_attachmentTableView setHidden:YES];
  
  [self _clearContent];
}

- (void)setupNotifications:(MPDocumentWindowController *)windowController {
  /* Register for Entry selection */
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didChangeSelectedEntry:)
                                               name:MPDidChangeSelectedEntryNotification
                                             object:windowController.entryViewController];
  
  /* Register for Group selection */
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_didChangeSelectedGroup:)
                                               name:MPOutlineViewDidChangeGroupSelection
                                             object:windowController.outlineViewController.outlineDelegate];
}

- (void)_updateInfoString {
  NSDate *modificationDate;
  NSDate *creationDate;
  if(_showsEntry) {
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
  if(self.showsEntry && self.selectedEntry) {
    [self _showEntry];
  }
  else if(!self.showsEntry && self.selectedGroup) {
    [self _showGroup];
  }
  else {
    [self _clearContent];
  }
  [self _updateAttachments];
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
  [self.notesTextField bind:NSValueBinding toObject:self.selectedEntry withKeyPath:MPEntryNotesUndoableKey options:nil];
  
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
  [self.notesTextField setStringValue:@""];
  
  [self _setInputEnabled:YES];
}

- (void)_clearContent {
  
  [self _setInputEnabled:NO];
  
  [self.itemNameTextfield unbind:NSValueBinding];
  [self.passwordTextField unbind:NSValueBinding];
  [self.usernameTextField unbind:NSValueBinding];
  [self.titleTextField unbind:NSValueBinding];
  [self.URLTextField unbind:NSValueBinding];
  [self.notesTextField unbind:NSValueBinding];
  
  [self.itemNameTextfield setStringValue:NSLocalizedString(@"INSPECTOR_NO_SELECTION", @"No item selected in inspector")];
  [self.itemImageView setImage:[NSImage imageNamed:NSImageNameActionTemplate]];
  
  [self.itemNameTextfield setStringValue:@""];
  [self.passwordTextField setStringValue:@""];
  [self.usernameTextField setStringValue:@""];
  [self.titleTextField setStringValue:@""];
  [self.URLTextField setStringValue:@""];
  [self.notesTextField setStringValue:@""];
  
}

- (void)_setInputEnabled:(BOOL)enabled {
  
  [self.itemImageView setAction: enabled ? @selector(_showImagePopup:) : NULL ];
  [self.itemImageView setEnabled:enabled];
  [self.itemNameTextfield setTextColor: enabled ? [NSColor controlTextColor] : [NSColor disabledControlTextColor] ];
  [self.itemNameTextfield setEnabled:enabled];
  [self.titleTextField setEnabled:enabled];
  
  enabled &= self.showsEntry;
  [self.passwordTextField setEnabled:enabled];
  [self.usernameTextField setEnabled:enabled];
  [self.URLTextField setEnabled:enabled];
  [self.generatePasswordButton setEnabled:enabled];
  [self.notesTextField setEditable:enabled];
  
}

- (void)_updateAttachments {
  if(self.selectedEntry && self.showsEntry) {
    if([self.selectedEntry isKindOfClass:[Kdb4Entry class]]) {
      [self.attachmentController bind:NSContentArrayBinding toObject:self.selectedEntry withKeyPath:@"binaries" options:nil];
    }
  }
  else {
    [self.attachmentController unbind:NSContentArrayBinding];
    [self.attachmentController setContent:nil];
  }
  [self.attachmentTableView setHidden:(0 == [[self.attachmentController arrangedObjects] count])];
}

#pragma mark Actions

- (void)_showImagePopup:(id)sender {
  [self _showPopopver:[[[MPIconSelectViewController alloc] init] autorelease]  atView:self.itemImageView onEdge:NSMinYEdge];
}

- (void)closeActivePopup:(id)sender {
  [_activePopover close];
}

- (IBAction)_popUpPasswordGenerator:(id)sender {
  [self _showPopopver:[[[MPPasswordCreatorViewController alloc] init] autorelease] atView:self.passwordTextField onEdge:NSMinYEdge];
}

- (void)_showPopopver:(NSViewController *)viewController atView:(NSView *)view onEdge:(NSRectEdge)edge {
  _activePopover = [[NSPopover alloc] init];
  _activePopover.behavior = NSPopoverBehaviorTransient;
  _activePopover.contentViewController = viewController;
  [_activePopover showRelativeToRect:NSZeroRect ofView:view preferredEdge:edge];
  _activePopover = nil;
}

#pragma mark Notificiations
- (void)_didChangeSelectedEntry:(NSNotification *)notification {
  MPEntryViewController *entryViewController = [notification object];
  if(entryViewController) {
    self.selectedEntry = entryViewController.selectedEntry;
  }
}

- (void)_didChangeSelectedGroup:(NSNotification *)notification {
  MPOutlineViewDelegate *outlineViewDelegae = [notification object];
  if(outlineViewDelegae) {
    self.selectedGroup = outlineViewDelegae.selectedGroup;
  }
}

#pragma mark Properties
- (void)setSelectedEntry:(KdbEntry *)selectedEntry {
  if(_selectedEntry != selectedEntry) {
    _selectedEntry = selectedEntry;
    self.showsEntry = YES;
    [self _updateContent];
  }
}

- (void)setSelectedGroup:(KdbGroup *)selectedGroup {
  if(_selectedGroup != selectedGroup) {
    _selectedGroup = selectedGroup;
    self.showsEntry = NO;
    [self _updateContent];
  }
}

#pragma mark NSTableViewDelegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:tableView];
  BinaryRef *binaryRef = [self.attachmentController arrangedObjects][row];
  [tableCellView.textField bind:NSValueBinding toObject:binaryRef withKeyPath:@"key" options:nil];
  [[tableCellView.textField cell] setBackgroundStyle:NSBackgroundStyleRaised];
  [[tableCellView.imageView cell] setBackgroundStyle:NSBackgroundStyleLight];
  return tableCellView;
}

@end
