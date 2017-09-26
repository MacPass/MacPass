//
//  MPMainWindowController.m
//  MacPass
//
//  Created by Michael Starke on 24.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
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

#import "MPDocumentWindowController.h"
#import "MPActionHelper.h"
#import "MPAppDelegate.h"
#import "MPAutotypeDaemon.h"
#import "MPConstants.h"
#import "MPContextToolbarButton.h"
#import "MPDatabaseSettingsWindowController.h"
#import "MPDocument.h"
#import "MPDocumentWindowDelegate.h"
#import "MPDuplicateEntryOptionsWindowController.h"
#import "MPEntryViewController.h"
#import "MPFixAutotypeWindowController.h"
#import "MPInspectorViewController.h"
#import "MPOutlineViewController.h"
#import "MPPasswordEditWindowController.h"
#import "MPPasswordInputController.h"
#import "MPSettingsHelper.h"
#import "MPToolbarDelegate.h"

#import "KeePassKit/KeePassKit.h"

typedef NS_ENUM(NSUInteger, MPAlertContext) {
  MPAlertLossySaveWarning,
};

typedef void (^MPPasswordChangedBlock)(BOOL didChangePassword);

@interface MPDocumentWindowController () {
@private
  id _firstResponder;
}

@property (strong) IBOutlet NSSplitView *splitView;

@property (strong) NSToolbar *toolbar;

@property (strong) MPPasswordInputController *passwordInputController;
@property (strong) MPEntryViewController *entryViewController;
@property (strong) MPOutlineViewController *outlineViewController;
@property (strong) MPInspectorViewController *inspectorViewController;
@property (strong) MPDatabaseSettingsWindowController *documentSettingsWindowController;
@property (strong) MPDocumentWindowDelegate *documentWindowDelegate;
@property (strong) MPPasswordEditWindowController *passwordEditWindowController;
@property (strong) MPToolbarDelegate *toolbarDelegate;
@property (strong) MPFixAutotypeWindowController *fixAutotypeWindowController;

//@property (nonatomic, copy) MPPasswordChangedBlock passwordChangedBlock;

@end

@implementation MPDocumentWindowController

- (NSString *)windowNibName {
  return @"DocumentWindow";
}

-(id)init {
  self = [super initWithWindow:nil];
  if( self ) {
    _firstResponder = nil;
    _toolbarDelegate = [[MPToolbarDelegate alloc] init];
    _outlineViewController = [[MPOutlineViewController alloc] init];
    _entryViewController = [[MPEntryViewController alloc] init];
    _inspectorViewController = [[MPInspectorViewController alloc] init];
    _documentWindowDelegate = [[MPDocumentWindowDelegate alloc] init];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark View Handling
- (void)windowDidLoad {
  [super windowDidLoad];
  
  self.window.delegate = self.documentWindowDelegate;
  [self.window registerForDraggedTypes:@[NSURLPboardType]];
  
  MPDocument *document = self.document;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didRevertDocument:) name:MPDocumentDidRevertNotifiation object:document];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didUnlockDatabase:) name:MPDocumentDidUnlockDatabaseNotification object:document];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didAddEntry:) name:MPDocumentDidAddEntryNotification object:document];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didAddGroup:) name:MPDocumentDidAddGroupNotification object:document];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didLockDatabase:) name:MPDocumentDidLockDatabaseNotification object:document];
  
  [self.entryViewController registerNotificationsForDocument:document];
  [self.inspectorViewController registerNotificationsForDocument:document];
  [self.outlineViewController regsiterNotificationsForDocument:document];
  [self.toolbarDelegate registerNotificationsForDocument:document];
  
  self.toolbar = [[NSToolbar alloc] initWithIdentifier:@"MainWindowToolbar"];
  self.toolbar.autosavesConfiguration = YES;
  self.toolbar.allowsUserCustomization = YES;
  self.toolbar.delegate = self.toolbarDelegate;
  self.window.toolbar = self.toolbar;
  self.toolbarDelegate.toolbar = self.toolbar;
  
  self.splitView.translatesAutoresizingMaskIntoConstraints = NO;
  
  NSView *outlineView = self.outlineViewController.view;
  NSView *inspectorView = self.inspectorViewController.view;
  NSView *entryView = self.entryViewController.view;
  [self.splitView addSubview:outlineView];
  [self.splitView addSubview:entryView];
  [self.splitView addSubview:inspectorView];
  
  [self.splitView setHoldingPriority:NSLayoutPriorityDefaultLow+2 forSubviewAtIndex:0];
  [self.splitView setHoldingPriority:NSLayoutPriorityDefaultLow+1 forSubviewAtIndex:2];
  
  BOOL showInspector = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyShowInspector];
  if(!showInspector) {
    [inspectorView removeFromSuperview];
  }
  
  if(document.encrypted) {
    [self showPasswordInput];
  }
  else {
    [self showEntries];
  }
  
  self.splitView.autosaveName = @"SplitView";
}

- (NSSearchField *)searchField {
  return self.toolbarDelegate.searchField;
}

- (void)_setContentViewController:(MPViewController *)viewController {
  
  NSView *newContentView = nil;
  if(viewController && viewController.view) {
    newContentView = viewController.view;
  }
  NSView *contentView = self.window.contentView;
  NSView *oldSubView = nil;
  if(contentView.subviews.count == 1) {
    oldSubView = contentView.subviews.firstObject;
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
  [self.window makeFirstResponder:viewController.reconmendedFirstResponder];
}

#pragma mark MPDocument notifications
- (void)_didRevertDocument:(NSNotification *)notification {
  [self.outlineViewController clearSelection];
  [self showPasswordInput];
}

- (void)_didAddEntry:(NSNotification *)notification {
  [self showInspector:self];
}

- (void)_didAddGroup:(NSNotification *)notification {
  [self showInspector:self];
}

- (void)_didLockDatabase:(NSNotification *)notification {
  [self showPasswordInput];
}

- (void)_didUnlockDatabase:(NSNotification *)notification {
  [self showEntries];
  /* Show password reminders */
  [self _presentPasswordIntervalAlerts];
}


#pragma mark Actions
- (void)saveDocument:(id)sender {
  MPDocument *document = self.document;
  /* did we open as legacy ?
  
  NSString *fileType = document.fileType;
  if([fileType isEqualToString:MPKdbxDocumentUTI]) {
    if(document.tree.minimumVersion.format != KPKDatabaseFormatKdb) {
      NSAlert *alert = [[NSAlert alloc] init];
      alert.alertStyle = NSWarningAlertStyle;
      alert.messageText = NSLocalizedString(@"WARNING_ON_LOSSY_SAVE", "");
      alert.informativeText = NSLocalizedString(@"WARNING_ON_LOSSY_SAVE_DESCRIPTION", "Informative Text displayed when saving would yield data loss");
      
      [alert addButtonWithTitle:NSLocalizedString(@"SAVE_LOSSY", "Save lossy")];
      [alert addButtonWithTitle:NSLocalizedString(@"CHANGE_FORMAT", "")];
      [alert addButtonWithTitle:NSLocalizedString(@"CANCEL", "Cancel")];
      [alert beginSheetModalForWindow:((NSDocument *)self.document).windowForSheet completionHandler:^(NSModalResponse returnCode) {
        switch(returnCode) {
          case NSAlertFirstButtonReturn:
            // save lossy
            [self.document saveDocument:nil];
            return;
            
          case NSAlertSecondButtonReturn:
            [alert.window orderOut:nil];
            [self.document saveDocumentAs:nil];
            return;
            
          case NSAlertThirdButtonReturn:
          default:
            return; // Cancel or unknown
        }
      }];
      return;
    }
  }
  else*/
  if(!document.compositeKey) {
    [self editPasswordWithCompetionHandler:^(NSInteger result) {
      if(result == NSModalResponseOK) {
        [self saveDocument:sender];
      }
    }];
    return;
  }
  else if(document.shouldEnforcePasswordChange) {
    [self editPasswordWithCompetionHandler:^(NSInteger result) {
      if(result == NSModalResponseOK) {
        [self saveDocument:sender];
      }
    }];
    [self _presentPasswordIntervalAlerts];
    return;
  }
  /* All set and good ready to save */
  [self.document saveDocument:sender];
}
- (void)saveDocumentAs:(id)sender {
  MPDocument *document = self.document;
  if(document.compositeKey) {
    [self.document saveDocumentAs:sender];
    return;
  }
  /* we need to make sure that a password is set */
  [self editPasswordWithCompetionHandler:^(NSInteger result) {
    if(result == NSModalResponseOK) {
      [self saveDocumentAs:sender];
    }
  }];
}

- (void)exportAsXML:(id)sender {
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  MPDocument *document = self.document;
  savePanel.nameFieldStringValue = document.displayName;
  savePanel.allowsOtherFileTypes = YES;
  savePanel.allowedFileTypes = @[(id)kUTTypeXML];
  savePanel.canSelectHiddenExtension = YES;
  [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
    if(result == NSFileHandlingPanelOKButton) {
      [document writeXMLToURL:savePanel.URL];
    }
  }];
}

- (void)importFromXML:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  MPDocument *document = self.document;
  openPanel.allowsMultipleSelection = NO;
  openPanel.canChooseDirectories = NO;
  openPanel.canChooseFiles = YES;
  openPanel.allowedFileTypes = @[(id)kUTTypeXML];
  [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
    if(result == NSFileHandlingPanelOKButton) {
      [document readXMLfromURL:openPanel.URL];
      [self.outlineViewController showOutline];
    }
  }];
}

- (void)mergeWithOther:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  MPDocument *document = self.document;
  openPanel.allowsMultipleSelection = NO;
  openPanel.canChooseDirectories = NO;
  openPanel.canChooseFiles = YES;
  openPanel.message = NSLocalizedString(@"SELECT_FILE_TO_MERGE", @"Message for the dialog to open a file for merge");
  //openPanel.allowedFileTypes = @[(id)kUTTypeXML];
  [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
    if(result == NSFileHandlingPanelOKButton) {
      [document mergeWithContentsFromURL:openPanel.URL key:document.compositeKey];
    }
  }];
}

- (void)fixAutotype:(id)sender {
  if(!self.fixAutotypeWindowController) {
    self.fixAutotypeWindowController = [[MPFixAutotypeWindowController alloc] init];
  }
  [self.document addWindowController:self.fixAutotypeWindowController];
  [self.fixAutotypeWindowController.window makeKeyAndOrderFront:sender];
}

- (void)showPasswordInput {
  if(!self.passwordInputController) {
    self.passwordInputController = [[MPPasswordInputController alloc] init];
  }
  [self _setContentViewController:self.passwordInputController];
  [self.passwordInputController requestPasswordWithCompletionHandler:^BOOL(NSString *password, NSURL *keyURL, BOOL cancel, NSError *__autoreleasing *error) {
    if(cancel) {
      return NO;
    }
    return [((MPDocument *)self.document) unlockWithPassword:password keyFileURL:keyURL error:error];
  }];
}

- (void)editPassword:(id)sender {
  [self editPasswordWithCompetionHandler:nil];
}

- (void)editPasswordWithCompetionHandler:(void (^)(NSInteger result))handler {
  if(!self.passwordEditWindowController) {
    self.passwordEditWindowController = [[MPPasswordEditWindowController alloc] init];
  }
  [self.document addWindowController:self.passwordEditWindowController];
  
  [self.window beginSheet:self.passwordEditWindowController.window completionHandler:^(NSModalResponse returnCode) {
    if(handler) {
      handler(returnCode);
    }
    [self.passwordEditWindowController.document removeWindowController:self.passwordEditWindowController];
    self.passwordEditWindowController = nil;
  }];
}

- (void)showDatabaseSettings:(id)sender {
  [self _showDatabaseSetting:MPDatabaseSettingsTabGeneral];
}

- (void)editTemplateGroup:(id)sender {
  [self _showDatabaseSetting:MPDatabaseSettingsTabAdvanced];
}

- (void)editTrashGroup:(id)sender {
  [self _showDatabaseSetting:MPDatabaseSettingsTabAdvanced];
}

- (IBAction)lock:(id)sender {
  MPDocument *document = [self document];
  if(!document.compositeKey.hasPasswordOrKeyFile) {
    return; // Document needs a password/keyfile to be lockable
  }
  if(document.encrypted) {
    return; // Document already locked
  }
  [document lockDatabase:sender];
}

- (void)createGroup:(id)sender {
  id<MPTargetNodeResolving> target = [NSApp targetForAction:@selector(currentTargetGroups)];
  NSArray *groups = [target currentTargetGroups];
  MPDocument *document = self.document;
  if(groups.count == 1) {
    [document createGroup:groups.firstObject];
  }
  else {
    [document createGroup:document.root];
  }
}

- (void)createEntry:(id)sender {
  id<MPTargetNodeResolving> target = [NSApp targetForAction:@selector(currentTargetGroups)];
  NSArray *groups = [target currentTargetGroups];
  if(groups.count == 1) {
    [(MPDocument *)self.document createEntry:groups.firstObject];
  }
}

- (void)delete:(id)sender {
  id<MPTargetNodeResolving> target = [NSApp targetForAction:@selector(currentTargetNodes)];
  NSArray *nodes = [target currentTargetNodes];
  for(KPKNode *node in nodes) {
    [self.document deleteNode:node];
  }
}
- (void)duplicateEntryWithOptions:(id)sender {
  MPDuplicateEntryOptionsWindowController *wc = [[MPDuplicateEntryOptionsWindowController alloc] init];
  
  [self.window beginSheet:wc.window completionHandler:^(NSModalResponse returnCode) {
    if(returnCode == NSModalResponseOK) {
      
      KPKCopyOptions options = kKPKCopyOptionNone;
      if(wc.referenceUsername) {
        options |= kKPKCopyOptionReferenceUsername;
      }
      if(wc.referencePassword) {
        options |= kKPKCopyOptionReferencePassword;
      }
      if(wc.duplicateHistory) {
        options |= kKPKCopyOptionCopyHistory;
      }
      [((MPDocument *)self.document) duplicateEntryWithOptions:options];
    }
  }];
}

- (void)pickExpiryDate:(id)sender {
  [self.inspectorViewController pickExpiryDate:sender];
}

- (void)showPluginData:(id)sender {
  [self.inspectorViewController showPluginData:sender];
}

- (void)toggleInspector:(id)sender {
  NSView *inspectorView = self.inspectorViewController.view;
  BOOL inspectorWasVisible = [self _isInspectorVisible];
  if(inspectorWasVisible) {
    [inspectorView removeFromSuperview];
  }
  else {
    [self.splitView addSubview:inspectorView];
    [self.splitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[inspectorView(>=200)]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(inspectorView)]];
  }
  [[NSUserDefaults standardUserDefaults] setBool:!inspectorWasVisible forKey:kMPSettingsKeyShowInspector];
}

- (void)performAutotypeForEntry:(id)sender {
  id<MPTargetNodeResolving> entryResolver = [NSApp targetForAction:@selector(currentTargetEntries)];
  NSArray *entries = [entryResolver currentTargetEntries];
  if(entries.count == 1) {
    [[MPAutotypeDaemon defaultDaemon] performAutotypeForEntry:entries.firstObject];
  }
}

- (void)showInspector:(id)sender {
  if(![self _isInspectorVisible]) {
    [self toggleInspector:sender];
  }
}

- (void)focusEntries:(id)sender {
  [[self window] makeFirstResponder:[self.entryViewController reconmendedFirstResponder]];
}

- (void)focusGroups:(id)sender {
  [self.window makeFirstResponder:[self.outlineViewController reconmendedFirstResponder]];
}

- (void)focusInspector:(id)sender {
  [self.window makeFirstResponder:[self.inspectorViewController reconmendedFirstResponder]];
}

- (void)showEntries {
  NSView *contentView = self.window.contentView;
  if(self.splitView == contentView) {
    return; // We are displaying the entries already
  }
  if(contentView.subviews.count == 1) {
    [contentView.subviews.firstObject removeFromSuperviewWithoutNeedingDisplay];
  }
  [contentView addSubview:self.splitView];
  NSView *outlineView = self.outlineViewController.view;
  NSView *inspectorView = self.inspectorViewController.view;
  NSView *entryView = self.entryViewController.view;
  
  /*
   The current easy way to prevent layout hiccups is to add the inspector
   Add all needed constraints an then remove it again, if it was hidden
   */
  BOOL removeInspector = NO;
  if(![inspectorView superview]) {
    [self.splitView addSubview:inspectorView];
    removeInspector = YES;
  }
  /* Maybe we should consider not double adding constraints */
  NSDictionary *views = NSDictionaryOfVariableBindings(outlineView, inspectorView, entryView, _splitView);
  [self.splitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[outlineView(>=150)]-1-[entryView(>=350)]-1-[inspectorView(>=200)]|"
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
  [self.outlineViewController showOutline];
  
  /* Restore the State the inspector view was in before the view change */
  if(removeInspector) {
    [inspectorView removeFromSuperview];
  }
  [contentView layoutSubtreeIfNeeded];
}

#pragma mark Validation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  return ([self.document validateMenuItem:menuItem]);
}

#pragma mark NSAlert handling
- (void)_presentPasswordIntervalAlerts {
  MPDocument *document = [self document];
  if(document.shouldEnforcePasswordChange) {
    NSAlert *alert = [[NSAlert alloc] init];
    
    alert.alertStyle = NSCriticalAlertStyle;
    alert.messageText = NSLocalizedString(@"ENFORCE_PASSWORD_CHANGE_ALERT_TITLE", "");
    alert.informativeText = NSLocalizedString(@"ENFORCE_PASSWORD_CHANGE_ALERT_DESCRIPTION", "");
    
    [alert addButtonWithTitle:NSLocalizedString(@"CHANGE_PASSWORD_WITH_DOTS", "")];
    [alert addButtonWithTitle:NSLocalizedString(@"CANCEL", "")];
    alert.buttons[1].keyEquivalent = [NSString stringWithFormat:@"%c", 0x1b];
    
    [alert beginSheetModalForWindow:[self.document windowForSheet] completionHandler:^(NSModalResponse returnCode) {
      if(NSAlertSecondButtonReturn == returnCode) {
        return;
      }
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self editPassword:nil];
      });
    }];
  }
  else if(document.shouldRecommendPasswordChange) {
    NSAlert *alert = [[NSAlert alloc] init];
    
    alert.alertStyle = NSInformationalAlertStyle;
    alert.messageText = NSLocalizedString(@"RECOMMEND_PASSWORD_CHANGE_ALERT_TITLE", "");
    alert.informativeText = NSLocalizedString(@"RECOMMEND_PASSWORD_CHANGE_ALERT_DESCRIPTION", "");
    
    [alert addButtonWithTitle:NSLocalizedString(@"CHANGE_PASSWORD_WITH_DOTS", "")];
    [alert addButtonWithTitle:NSLocalizedString(@"CANCEL", "")];
    alert.buttons[1].keyEquivalent = [NSString stringWithFormat:@"%c", 0x1b];
    
    
    [alert beginSheetModalForWindow:[self.document windowForSheet]completionHandler:^(NSModalResponse returnCode) {
      if(returnCode == NSAlertSecondButtonReturn) {
        return;
      }
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self editPassword:nil];
      });
    }];
  }
}

#pragma mark Sheet handling
- (void)_showDatabaseSetting:(MPDatabaseSettingsTab)tab {
  if(!self.documentSettingsWindowController) {
    self.documentSettingsWindowController = [[MPDatabaseSettingsWindowController alloc] init];
  }
  [self.document addWindowController:self.documentSettingsWindowController];
  [self.documentSettingsWindowController showSettingsTab:tab];
  [self.window beginSheet:self.documentSettingsWindowController.window completionHandler:^(NSModalResponse returnCode) {
    [self.documentSettingsWindowController.document removeWindowController:self.documentSettingsWindowController];
    self.documentSettingsWindowController = nil;
  }];
}

#pragma mark -
#pragma mark UI Helper

- (BOOL)_isInspectorVisible {
  NSView *inspectorView = self.inspectorViewController.view;
  return (nil != inspectorView.superview);
}

@end
