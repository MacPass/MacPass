//
//  MPMainWindowController.m
//  MacPass
//
//  Created by Michael Starke on 24.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocumentWindowController.h"
#import "MPDocument.h"
#import "MPPasswordInputController.h"
#import "MPEntryViewController.h"
#import "MPToolbarDelegate.h"
#import "MPOutlineViewController.h"
#import "MPInspectorViewController.h"
#import "MPAppDelegate.h"
#import "MPActionHelper.h"
#import "MPDatabaseSettingsWindowController.h"
#import "MPConstants.h"
#import "MPSettingsHelper.h"
#import "MPDocumentWindowDelegate.h"

#import "MPContextToolbarButton.h"

@interface MPDocumentWindowController () {
@private
  id _firstResponder;
  BOOL _saveAfterPasswordEdit; // Flag to indicat that the document needs to be saved after password edit did finish
}

@property (strong) IBOutlet NSSplitView *splitView;

@property (strong) NSToolbar *toolbar;

@property (strong) MPPasswordInputController *passwordInputController;
@property (strong) MPEntryViewController *entryViewController;
@property (strong) MPOutlineViewController *outlineViewController;
@property (strong) MPInspectorViewController *inspectorViewController;
@property (strong) MPDatabaseSettingsWindowController *documentSettingsWindowController;
@property (strong) MPDocumentWindowDelegate *documentWindowDelegate;

@property (strong) MPToolbarDelegate *toolbarDelegate;

@end

@implementation MPDocumentWindowController

-(id)init {
  self = [super initWithWindowNibName:@"DocumentWindow" owner:self];
  if( self ) {
    _firstResponder = nil;
    _toolbarDelegate = [[MPToolbarDelegate alloc] init];
    _outlineViewController = [[MPOutlineViewController alloc] init];
    _entryViewController = [[MPEntryViewController alloc] init];
    _inspectorViewController = [[MPInspectorViewController alloc] init];
    _documentWindowDelegate = [[MPDocumentWindowDelegate alloc] init];
    _saveAfterPasswordEdit = NO;
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark View Handling
- (void)windowDidLoad {
  [super windowDidLoad];
  
  /* Drag and Drop of URLS is working, but the current
    und/Redo system cannot guarantee that the undomanager is found
   when no window is active, thus this needs to be addresed when switching to KeePassKit
   
  [[self window] setDelegate:self.documentWindowDelegate];
  [[self window] registerForDraggedTypes:@[NSURLPboardType]];
  */
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didRevertDocument:) name:MPDocumentDidRevertNotifiation object:[self document]];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_setPasswordAndSave) name:MPDocumentRequestPasswordSaveNotification object:[self document]];
  
  [_entryViewController setupNotifications:self];
  [_inspectorViewController setupNotifications:self];
  [_outlineViewController setupNotifications:self];
  
  
  
  _toolbar = [[NSToolbar alloc] initWithIdentifier:@"MainWindowToolbar"];
  [_toolbar setAutosavesConfiguration:YES];
  [self.toolbar setAllowsUserCustomization:YES];
  [self.toolbar setDelegate:self.toolbarDelegate];
  [self.window setToolbar:self.toolbar];
  
  [self.splitView setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  NSView *outlineView = [_outlineViewController view];
  NSView *inspectorView = [_inspectorViewController view];
  NSView *entryView = [_entryViewController view];
  [_splitView addSubview:outlineView];
  [_splitView addSubview:entryView];
  [_splitView addSubview:inspectorView];
  
  [_splitView setHoldingPriority:NSLayoutPriorityDefaultLow+2 forSubviewAtIndex:0];
  [_splitView setHoldingPriority:NSLayoutPriorityDefaultLow+1 forSubviewAtIndex:2];
  
  BOOL showInspector = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyShowInspector];
  if(!showInspector) {
    [inspectorView removeFromSuperview];
  }
  
  MPDocument *document = [self document];
  if(!document.decrypted) {
    [self showPasswordInput];
  }
  else {
    [self showEntries];
  }
  
  [_splitView setAutosaveName:@"SplitView"];
}

- (void)_setContentViewController:(MPViewController *)viewController {
  
  NSView *newContentView = nil;
  if(viewController && viewController.view) {
    newContentView = viewController.view;
  }
  NSView *contentView = [[self window] contentView];
  NSView *oldSubView = nil;
  if([[contentView subviews] count] == 1) {
    oldSubView = [contentView subviews][0];
  }
  if(oldSubView == newContentView) {
    return; // View is already present
  }
  [oldSubView removeFromSuperviewWithoutNeedingDisplay];
  [contentView addSubview:newContentView];
  [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[newContentView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(newContentView)]];
  
  NSNumber *border = @([[self window] contentBorderThicknessForEdge:NSMinYEdge]);
  [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[newContentView]-border-|"
                                                                      options:0
                                                                      metrics:NSDictionaryOfVariableBindings(border)
                                                                        views:NSDictionaryOfVariableBindings(newContentView)]];
  
  [contentView layout];
  [viewController updateResponderChain];
  [self.window makeFirstResponder:[viewController reconmendedFirstResponder]];
}

- (void)_didRevertDocument:(NSNotification *)notification {
  [self.outlineViewController clearSelection];
  [self showPasswordInput];
}

#pragma mark Actions
- (void)exportDatabase:(id)sender {
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  [savePanel setAllowsOtherFileTypes:YES];
  [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
    if(result == NSFileHandlingPanelOKButton) {
      [[self document] writeXMLToURL:savePanel.URL];
    }
  }];
}
- (void)performFindPanelAction:(id)sender {
  [self.entryViewController showFilter:sender];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  MPDocument *document = [self document];
  SEL itemAction = [menuItem action];
  if(itemAction == @selector(showDatabaseSettings:)
     || itemAction == @selector(editPassword:)) {
    return document.decrypted && !document.isLocked;
  }
  
  BOOL enabled = YES;
  if(itemAction == @selector(exportDatabase:)) {
    enabled = (nil != document.treeV4);
  }
  if(itemAction == [MPActionHelper actionOfType:MPActionDelete]) {
    enabled &= (nil != document.selectedItem) && (document.selectedItem != document.trash);
  }
  
  enabled &= !( !document.decrypted || document.isLocked || document.isReadOnly );
  return enabled;
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
  MPDocument *document = [self document];
  if(!document.decrypted || document.isLocked || document.isReadOnly) {
    return NO;
  }
  MPActionType actionType = [MPActionHelper typeForAction:[theItem action]];
  switch (actionType) {
    case MPActionAddGroup:
    case MPActionAddEntry:
      return (nil != document.selectedGroup);
    case MPActionDelete: {
      BOOL valid = (nil != document.selectedItem);
      valid &= (document.selectedItem != document.trash);
      valid &= ![document isItemTrashed:document.selectedItem];
      return valid;
    }
    case MPActionLock:
      return document.hasPasswordOrKey;
      
    case MPActionToggleInspector:
      return (nil != [_splitView superview]);
      
    default:
      return YES;
  }
  return YES;
}

- (BOOL)validateAction:(SEL)action forItem:(id)item {
  MPDocument *document = [self document];
  if(!document.decrypted || document.isLocked || document.isReadOnly) {
    return NO;
  }
  MPActionType actionType = [MPActionHelper typeForAction:action];
  switch (actionType) {
    case MPActionAddGroup:
    case MPActionAddEntry:
      // test if Group is in trash
      return (nil != document.selectedGroup);
    case MPActionDelete: {
      BOOL valid = (nil != document.selectedItem);
      valid &= (document.selectedItem != document.trash);
      valid &= ![document isItemTrashed:document.selectedItem];
      return valid;
    }
    case MPActionLock:
      return document.hasPasswordOrKey;
      
    case MPActionToggleInspector:
      return (nil != [_splitView superview]);
      
    default:
      return YES;
  }
  return YES;
}

- (void)showPasswordInput {
  if(!self.passwordInputController) {
    self.passwordInputController = [[MPPasswordInputController alloc] init];
  }
  [self _setContentViewController:self.passwordInputController];
  [self.passwordInputController requestPassword];
}

- (void)editPassword:(id)sender {
  [self _showDatabaseSetting:MPDatabaseSettingsTabPassword];
}

- (void)showDatabaseSettings:(id)sender {
  [self _showDatabaseSetting:MPDatabaseSettingsTabGeneral];
}

- (void)editTemplateGroup:(id)sender {
  [self _showDatabaseSetting:MPDatabaseSettingsTabTemplates];
}

- (void)editTrashGroup:(id)sender {
  [self _showDatabaseSetting:MPDatabaseSettingsTabAdvanced];
}

- (IBAction)lock:(id)sender {
  MPDocument *document = [self document];
  if(!document.hasPasswordOrKey) {
    return; // Document needs a password/keyfile to be lockable
  }
  if(document.isLocked) {
    return; // Document already locked
  }
  document.locked = YES;
  [self showPasswordInput];
}

- (void)createGroup:(id)sender {
  [_outlineViewController createGroup:nil];
}

- (void)createEntry:(id)sender {
  [_outlineViewController createEntry:nil];
}

- (void)toggleInspector:(id)sender {
  NSView *inspectorView = [_inspectorViewController view];
  BOOL inspectorVisible = NO;
  if([inspectorView superview]) {
    //[inspectorView animator]
    [inspectorView removeFromSuperview];
  }
  else {
    // Remove contraint on view removal.
    inspectorVisible = YES;
    [_splitView addSubview:inspectorView];
    [_splitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[inspectorView(>=200)]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:NSDictionaryOfVariableBindings(inspectorView)]];
  }
  [[NSUserDefaults standardUserDefaults] setBool:inspectorVisible forKey:kMPSettingsKeyShowInspector];
}

- (void)showEntries {
  NSView *contentView = [[self window] contentView];
  if(_splitView == contentView) {
    return; // We are displaying the entries already
  }
  if([[contentView subviews] count] == 1) {
    [[contentView subviews][0] removeFromSuperviewWithoutNeedingDisplay];
  }
  [contentView addSubview:_splitView];
  //[_splitView adjustSubviews];
  NSView *outlineView = [_outlineViewController view];
  NSView *inspectorView = [_inspectorViewController view];
  NSView *entryView = [_entryViewController view];
  
  /*
   The current easy way to prevent layout hickups is to add the inspect
   Add all neded contraints an then remove it again, if it was hidden
   */
  BOOL removeInspector = NO;
  if(![inspectorView superview]) {
    [_splitView addSubview:inspectorView];
    removeInspector = YES;
  }
  /* Maybe we should consider not double adding constraints */
  NSDictionary *views = NSDictionaryOfVariableBindings(outlineView, inspectorView, entryView, _splitView);
  [self.splitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[outlineView(>=150,<=250)]-1-[entryView(>=350)]-1-[inspectorView(>=200)]|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:views]];
  [self.splitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[outlineView]|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:views]];
  [self.splitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[entryView(>=300)]|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:views]];
  [self.splitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[inspectorView]|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:views]];
  
  NSNumber *border = @([[self window] contentBorderThicknessForEdge:NSMinYEdge]);
  [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_splitView]-border-|"
                                                                      options:0
                                                                      metrics:NSDictionaryOfVariableBindings(border)
                                                                        views:views]];
  [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_splitView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
  /* Restore the State the inspector view was in before the view change */
  if(removeInspector) {
    [inspectorView removeFromSuperview];
  }
  [contentView layoutSubtreeIfNeeded];
  
  MPDocument *document = [self document];
  document.locked = NO;
  
  [_entryViewController updateResponderChain];
  [_inspectorViewController updateResponderChain];
  [_outlineViewController updateResponderChain];
  [_outlineViewController showOutline];
}

#pragma mark MPDatabaseSettingsDelegate
- (void)didCancelDatabaseSettings {
  _saveAfterPasswordEdit = NO; // Just Reset the flag
}

- (void)didSaveDatabaseSettings {
  if (_saveAfterPasswordEdit) {
    _saveAfterPasswordEdit = NO;
  }
  [[self document] saveDocument:nil];
}

#pragma mark Helper

- (void)_setPasswordAndSave {
  _saveAfterPasswordEdit = YES;
  [self editPassword:nil];
}

- (void)_showDatabaseSetting:(MPDatabaseSettingsTab)tab {
  if(!self.documentSettingsWindowController) {
    _documentSettingsWindowController = [[MPDatabaseSettingsWindowController alloc] initWithDocument:[self document]];
    [_documentSettingsWindowController setDelegate:self];
  }
  [self.documentSettingsWindowController update];
  [self.documentSettingsWindowController showSettingsTab:tab];
  [[NSApplication sharedApplication] beginSheet:[self.documentSettingsWindowController window]
                                 modalForWindow:[self window]
                                  modalDelegate:nil
                                 didEndSelector:NULL
                                    contextInfo:NULL];
  
}

- (NSSearchField *)locateToolbarSearchField {
  for(NSToolbarItem *toolbarItem in [[self.window toolbar] items]) {
    NSView *view = [toolbarItem view];
    if([view isKindOfClass:[NSSearchField class]]) {
      return (NSSearchField *)view;
    }
  }
  return nil;
}

@end
