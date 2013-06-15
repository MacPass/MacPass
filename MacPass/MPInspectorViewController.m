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
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_activePopover release];
  [super dealloc];
}

- (void)didLoadView {
  
  [[self.itemImageView cell] setBackgroundStyle:NSBackgroundStyleRaised];
  [self.itemImageView setTarget:self];
  [_bottomBar setBorderType:HNHBorderTop];
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
}

- (void)_showEntry {
  [self.itemNameTextfield bind:NSValueBinding toObject:self.selectedEntry withKeyPath:MPEntryTitleUndoableKey options:nil];
  [self.itemImageView setImage:[MPIconHelper icon:(MPIconType)self.selectedEntry.image ]];
  [self.passwordTextField bind:NSValueBinding toObject:self.selectedEntry withKeyPath:MPEntryPasswordUndoableKey options:nil];
  [self.usernameTextField bind:NSValueBinding toObject:self.selectedEntry withKeyPath:MPEntryUsernameUndoableKey options:nil];
  [self.titleOrNameLabel setStringValue:NSLocalizedString(@"TITLE",@"")];
  [self.titleTextField bind:NSValueBinding toObject:self.selectedEntry withKeyPath:MPEntryTitleUndoableKey options:nil];
  [self.URLTextField bind:NSValueBinding toObject:self.selectedEntry withKeyPath:MPEntryUrlUndoableKey options:nil];
  
  [self _setInputEnabled:YES];
}

- (void)_showGroup {
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
  
  [self _setInputEnabled:YES];
}

- (void)_clearContent {
  
  [self _setInputEnabled:NO];
  
  [self.itemNameTextfield unbind:NSValueBinding];
  [self.passwordTextField unbind:NSValueBinding];
  [self.usernameTextField unbind:NSValueBinding];
  [self.titleTextField unbind:NSValueBinding];
  [self.URLTextField unbind:NSValueBinding];
  
  [self.itemNameTextfield setStringValue:NSLocalizedString(@"INSPECTOR_NO_SELECTION", @"No item selected in inspector")];
  [self.itemImageView setImage:[NSImage imageNamed:NSImageNameActionTemplate]];
  
  [self.itemNameTextfield setStringValue:@""];
  [self.passwordTextField setStringValue:@""];
  [self.usernameTextField setStringValue:@""];
  [self.titleTextField setStringValue:@""];
  [self.URLTextField setStringValue:@""];
  
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
@end
