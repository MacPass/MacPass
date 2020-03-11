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
#import "MPContextButton.h"
#import "MPDatabaseSettingsWindowController.h"
#import "MPDocument.h"
#import "MPDocumentWindowDelegate.h"
#import "MPDocumentSplitViewController.h"
#import "MPDuplicateEntryOptionsWindowController.h"
#import "MPEntryViewController.h"
#import "MPFixAutotypeWindowController.h"
#import "MPInspectorViewController.h"
#import "MPOutlineViewController.h"
#import "MPPasswordEditWindowController.h"
#import "MPPasswordInputController.h"
#import "MPSettingsHelper.h"
#import "MPToolbarDelegate.h"
#import "MPTitlebarColorAccessoryViewController.h"
#import "MPTouchBarButtonCreator.h"
#import "MPIconHelper.h"

#import "MPPluginHost.h"
#import "MPPlugin.h"

#import "KeePassKit/KeePassKit.h"

typedef NS_ENUM(NSUInteger, MPAlertContext) {
  MPAlertLossySaveWarning,
};

typedef void (^MPPasswordChangedBlock)(BOOL didChangePassword);

@interface MPDocumentWindowController () {
@private
  id _firstResponder;
}

@property (strong) NSToolbar *toolbar;

@property (strong) MPPasswordInputController *passwordInputController;
@property (strong) MPDocumentSplitViewController *splitViewController;

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
    _splitViewController = [[MPDocumentSplitViewController alloc] init];
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
  
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didUnlockDatabase:) name:MPDocumentDidUnlockDatabaseNotification object:document];
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didAddEntry:) name:MPDocumentDidAddEntryNotification object:document];
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didAddGroup:) name:MPDocumentDidAddGroupNotification object:document];
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didLockDatabase:) name:MPDocumentDidLockDatabaseNotification object:document];
  
  [self.splitViewController registerNotificationsForDocument:document];
  [self.toolbarDelegate registerNotificationsForDocument:document];
  
  self.toolbar = [[NSToolbar alloc] initWithIdentifier:@"MainWindowToolbar"];
  self.toolbar.autosavesConfiguration = YES;
  self.toolbar.allowsUserCustomization = YES;
  if (@available(macOS 10.14, *)) {
    self.toolbar.centeredItemIdentifier = MPToolbarItemIdentifierSearch;
  } else {
    // to not do any magic here
  }
  self.toolbar.delegate = self.toolbarDelegate;
  self.window.toolbar = self.toolbar;
  self.toolbarDelegate.toolbar = self.toolbar;
  
  if(document.encrypted) {
    [self showPasswordInput];
  }
  else {
    [self showEntries];
  }
  
  /*
   TODO: Add display for database color?
   NSTitlebarAccessoryViewController *tbc = [[MPTitlebarColorAccessoryViewController alloc] init];
   tbc.layoutAttribute = NSLayoutAttributeRight;
   [self.window addTitlebarAccessoryViewController:tbc];
   */
}

- (NSSearchField *)searchField {
  return self.toolbarDelegate.searchField;
}

- (void)setContentViewController:(NSViewController *)contentViewController {
  contentViewController.view.frame = self.window.contentView.frame;
  [super setContentViewController:contentViewController];
}

#pragma mark MPDocument notifications
- (void)_didRevertDocument:(NSNotification *)notification {
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
  if(!document.compositeKey) {
    [self editPasswordWithCompetionHandler:^(NSInteger result) {
      if(result == NSModalResponseOK) {
        [self saveDocument:sender];
      }
    }];
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
    if(result == NSModalResponseOK) {
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
  openPanel.prompt = NSLocalizedString(@"OPEN_BUTTON_IMPORT_XML_OPEN_PANEL", "Open button in the open panel to import an XML file");
  openPanel.message = NSLocalizedString(@"MESSAGE_XML_OPEN_PANEL", "Message in the open panel to import an XML file");
  [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
    if(result == NSModalResponseOK) {
      [document readXMLfromURL:openPanel.URL];
      [self.splitViewController showOutline];
    }
  }];
}

- (void)importWithPlugin:(id)sender {
  if(![sender isKindOfClass:NSMenuItem.class]) {
    return;
  }
  NSMenuItem *menuItem = sender;
  if(![menuItem.representedObject isKindOfClass:NSString.class]) {
    return;
  }
  
  NSWindow *sheetWindow = ((MPDocument *)self.document).windowForSheet;
  if(!sheetWindow) {
    return;
  }
  NSString *bundleIdentifier = menuItem.representedObject;
  MPPlugin<MPImportPlugin> *importPlugin = (MPPlugin<MPImportPlugin> *)[MPPluginHost.sharedHost pluginWithBundleIdentifier:bundleIdentifier];
  NSOpenPanel *openPanel = NSOpenPanel.openPanel;
  [importPlugin prepareOpenPanel:openPanel];
  [openPanel beginSheetModalForWindow:sheetWindow completionHandler:^(NSModalResponse result) {
    if(result == NSModalResponseOK) {
      KPKTree *importedTree = [importPlugin treeForRunningOpenPanel:openPanel];
      [self.document importTree:importedTree];
    }
  }];
}

- (void)exportWithPlugin:(id)sender {
  if(![sender isKindOfClass:NSMenuItem.class]) {
    return;
  }
  NSMenuItem *menuItem = sender;
  if(![menuItem.representedObject isKindOfClass:NSString.class]) {
    return;
  }
  
  NSWindow *sheetWindow = ((MPDocument *)self.document).windowForSheet;
  if(!sheetWindow) {
    return;
  }
  NSString *bundleIdentifier = menuItem.representedObject;
  MPPlugin<MPExportPlugin> *exportPlugin = (MPPlugin<MPExportPlugin> *)[MPPluginHost.sharedHost pluginWithBundleIdentifier:bundleIdentifier];
  NSSavePanel *savePanel = NSSavePanel.savePanel;
  [exportPlugin prepareSavePanel:savePanel];
  [savePanel beginSheetModalForWindow:sheetWindow completionHandler:^(NSModalResponse result) {
    if(result == NSModalResponseOK) {
      [exportPlugin exportTree:((MPDocument *)self.document).tree forRunningSavePanel:savePanel];
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
    if(result == NSModalResponseOK) {
      [document mergeWithContentsFromURL:openPanel.URL key:document.compositeKey];
    }
  }];
}

- (void)fixAutotype:(id)sender {
  if(!self.fixAutotypeWindowController) {
    self.fixAutotypeWindowController = [[MPFixAutotypeWindowController alloc] init];
  }
  self.fixAutotypeWindowController.document = self.document;
  [self.fixAutotypeWindowController.window makeKeyAndOrderFront:sender];
}

- (void)showPasswordInput {
  [self showPasswordInputWithMessage:nil];
}
- (void)showPasswordInputWithMessage:(NSString *)message {
  if(!self.passwordInputController) {
    self.passwordInputController = [[MPPasswordInputController alloc] init];
  }
  self.contentViewController = self.passwordInputController;
  [self.passwordInputController requestPasswordWithMessage:message cancelLabel:nil completionHandler:^BOOL(NSString *password, NSURL *keyURL, BOOL didCancel, NSError *__autoreleasing *error) {
    if(didCancel) {
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
  MPDocument *document = self.document;
  if(document.encrypted) {
    return; // Document already locked
  }
  if(!document.compositeKey) {
    [self editPasswordWithCompetionHandler:^(NSInteger result) {
      if(result == NSModalResponseOK) {
        [self lock:sender];
      }
    }];
    return;
  }
  [document lockDatabase:sender];
}

- (void)createGroup:(id)sender {
  id<MPTargetNodeResolving> target = [NSApp targetForAction:@selector(currentTargetGroups)];
  NSArray *groups = target.currentTargetGroups;
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
  NSArray *groups = target.currentTargetGroups;
  if(groups.count == 1) {
    [(MPDocument *)self.document createEntry:groups.firstObject];
  }
}

- (void)delete:(id)sender {
  id<MPTargetNodeResolving> target = [NSApp targetForAction:@selector(currentTargetNodes)];
  NSArray *nodes = target.currentTargetNodes;
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
  // FIXME: use propert responder chain
   [self.splitViewController.inspectorViewController pickExpiryDate:sender];
}

- (void)showPluginData:(id)sender {
  // FIXME: use propert responder chain
  [self.splitViewController.inspectorViewController showPluginData:sender];
}

- (void)toggleInspector:(id)sender {
  [self.splitViewController toggleInspector:sender];
}

- (void)performAutotypeForEntry:(id)sender {
  id<MPTargetNodeResolving> entryResolver = [NSApp targetForAction:@selector(currentTargetEntries)];
  NSArray *entries = entryResolver.currentTargetEntries;
  if(entries.count == 1) {
    [MPAutotypeDaemon.defaultDaemon performAutotypeForEntry:entries.firstObject];
  }
}

- (void)showInspector:(id)sender {
  if(![self _isInspectorVisible]) {
    [self toggleInspector:sender];
  }
}

- (void)focusEntries:(id)sender {
  // FIXME: use propert responder chain
  [self.window makeFirstResponder:[self.splitViewController.entryViewController reconmendedFirstResponder]];
}

- (void)focusGroups:(id)sender {
  // FIXME: use propert responder chain
  [self.window makeFirstResponder:[self.splitViewController.outlineViewController reconmendedFirstResponder]];
}

- (void)focusInspector:(id)sender {
  // FIXME: use propert responder chain
  [self.window makeFirstResponder:[self.splitViewController.inspectorViewController reconmendedFirstResponder]];
}

- (void)showEntries {
  self.contentViewController = self.splitViewController;
  [self.splitViewController showOutline];

}

- (void)showGroupInOutline:(id)sender {
  NSArray<KPKEntry *> *targetEntries = self.splitViewController.entryViewController.currentTargetEntries;
  if(targetEntries.count != 1) {
    return;
  }
  [self.splitViewController.outlineViewController selectGroup:targetEntries.lastObject.parent];
}

#pragma mark -
#pragma mark Actions forwarded to MPEntryViewController
- (void)copyUsername:(id)sender {
  [self.splitViewController.entryViewController copyUsername:sender];
}

- (void)copyPassword:(id)sender {
  [self.splitViewController.entryViewController copyPassword:sender];
}

- (void)copyCustomAttribute:(id)sender {
  [self.splitViewController.entryViewController copyCustomAttribute:sender];
}

- (void)copyAsReference:(id)sender {
  [self.splitViewController.entryViewController copyAsReference:sender];
}

- (void)copyURL:(id)sender {
  [self.splitViewController.entryViewController copyURL:sender];
}

- (void)openURL:(id)sender {
  [self.splitViewController.entryViewController openURL:sender];
}

#pragma mark Validation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  return ([self.document validateMenuItem:menuItem]);
}

#pragma mark NSAlert handling
- (void)_presentPasswordIntervalAlerts {
  MPDocument *document = self.document;
  if(document.shouldEnforcePasswordChange) {
    NSAlert *alert = [[NSAlert alloc] init];
    
    alert.alertStyle = NSAlertStyleCritical;
    alert.messageText = NSLocalizedString(@"ENFORCE_PASSWORD_CHANGE_ALERT_TITLE", "Message text for the enforce password change alert");
    alert.informativeText = NSLocalizedString(@"ENFORCE_PASSWORD_CHANGE_ALERT_DESCRIPTION", "Informative text for the enforce password change alert");
    
    [alert addButtonWithTitle:NSLocalizedString(@"CHANGE_PASSWORD_WITH_DOTS", "Single button to show the password change dialog")];
    
    [alert beginSheetModalForWindow:[self.document windowForSheet] completionHandler:^(NSModalResponse returnCode) {
      /* if sheet was stopped any other way, do nothing */
      if(returnCode != NSAlertFirstButtonReturn) {
        return;
      }
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self editPasswordWithCompetionHandler:^(NSInteger result) {
          /* if password was changed, reset change key and dismiss */
          if(result == NSModalResponseOK) {
            document.tree.metaData.enforceMasterKeyChangeOnce = NO;
          }
          else if(result == NSModalResponseCancel) {
            /* password was not changes, so keep nagging the user! */
            [self _presentPasswordIntervalAlerts];
          }
          else {
            // We might have been killed by locking so do nothing!
          }
        }];
      });
    }];
  }
  else if(document.shouldRecommendPasswordChange) {
    NSAlert *alert = [[NSAlert alloc] init];
    
    alert.alertStyle = NSAlertStyleInformational;
    alert.messageText = NSLocalizedString(@"RECOMMEND_PASSWORD_CHANGE_ALERT_TITLE", "Message text for the recommend password change alert");
    alert.informativeText = NSLocalizedString(@"RECOMMEND_PASSWORD_CHANGE_ALERT_DESCRIPTION", "Informative text for the recommend password change alert");
    
    [alert addButtonWithTitle:NSLocalizedString(@"CHANGE_PASSWORD_WITH_DOTS", "Button to show the password change dialog")];
    [alert addButtonWithTitle:NSLocalizedString(@"CHANGE_LATER", "Button to postpone the password change")];
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
  NSSplitViewItem *item = [self.splitViewController splitViewItemForViewController:self.splitViewController.inspectorViewController];
  return !item.isCollapsed;
}

- (NSTouchBar *)makeTouchBar {
  NSTouchBar *touchBar = [[NSTouchBar alloc] init];
  touchBar.delegate = self;
  touchBar.customizationIdentifier = MPTouchBarCustomizationIdentifierDocument;
  NSArray<NSTouchBarItemIdentifier> *defaultItemIdentifiers = @[MPTouchBarItemIdentifierSearch, MPTouchBarItemIdentifierEditPopover, MPTouchBarItemIdentifierCopyUsername, MPTouchBarItemIdentifierCopyPassword,  MPTouchBarItemIdentifierPerformAutotype, NSTouchBarItemIdentifierFlexibleSpace, MPTouchBarItemIdentifierLock];
  touchBar.defaultItemIdentifiers = defaultItemIdentifiers;
  touchBar.customizationAllowedItemIdentifiers = defaultItemIdentifiers;
  return touchBar;
}

- (NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier  API_AVAILABLE(macos(10.12.2)) {
#pragma mark primary touchbar elements
  if([identifier isEqualToString:MPTouchBarItemIdentifierSearch]) {
    return [MPTouchBarButtonCreator touchBarButtonWithImage:[NSImage imageNamed:NSImageNameTouchBarSearchTemplate]
                                                 identifier:MPTouchBarItemIdentifierSearch
                                                     target:self
                                                   selector:@selector(focusSearchField)
                                         customizationLabel:NSLocalizedString(@"TOUCHBAR_SEARCH","Touchbar button label for searching the database")];
  }
  
  if([identifier isEqualToString:MPTouchBarItemIdentifierEditPopover]) {
    NSTouchBar *secondaryTouchBar = [[NSTouchBar alloc] init];
    secondaryTouchBar.delegate = self;
    secondaryTouchBar.defaultItemIdentifiers = @[MPTouchBarItemIdentifierNewEntry, MPTouchBarItemIdentifierNewGroup, MPTouchBarItemIdentifierDelete];
    return [MPTouchBarButtonCreator popoverTouchBarButton:NSLocalizedString(@"TOUCHBAR_EDIT","Touchbar button label for opening the popover to edit")
                                               identifier:MPTouchBarItemIdentifierEditPopover
                                          popoverTouchBar:secondaryTouchBar
                                       customizationLabel:NSLocalizedString(@"TOUCHBAR_EDIT","Touchbar button label for opening the popover to edit")];
  }
  
  if([identifier isEqualToString:MPTouchBarItemIdentifierCopyUsername]) {
    return [MPTouchBarButtonCreator touchBarButtonWithTitle:NSLocalizedString(@"TOUCHBAR_COPY_USERNAME","Touchbar button label for copying the username")
                                                 identifier:MPTouchBarItemIdentifierCopyUsername
                                                     target:self
                                                   selector:@selector(copyUsername:)
                                         customizationLabel:NSLocalizedString(@"TOUCHBAR_COPY_USERNAME","Touchbar button label for copying the username")];
  }
  
  if([identifier isEqualToString:MPTouchBarItemIdentifierCopyPassword]) {
    return [MPTouchBarButtonCreator touchBarButtonWithTitle:NSLocalizedString(@"TOUCHBAR_COPY_PASSWORD","Touchbar button label for copying the password")
                                                 identifier:MPTouchBarItemIdentifierCopyPassword
                                                     target:self
                                                   selector:@selector(copyPassword:)
                                         customizationLabel:NSLocalizedString(@"TOUCHBAR_COPY_PASSWORD","Touchbar button label for copying the password")];
  }
  
  if([identifier isEqualToString:MPTouchBarItemIdentifierPerformAutotype]) {
    return [MPTouchBarButtonCreator touchBarButtonWithTitle:NSLocalizedString(@"TOUCHBAR_PERFORM_AUTOTYPE","Touchbar button label for performing autotype")
                                                 identifier:MPTouchBarItemIdentifierPerformAutotype
                                                     target:self
                                                   selector:@selector(performAutotypeForEntry:)
                                         customizationLabel:NSLocalizedString(@"TOUCHBAR_PERFORM_AUTOTYPE","Touchbar button label for performing autotype")];
  }
  if([identifier isEqualToString:MPTouchBarItemIdentifierLock]) {
    return [MPTouchBarButtonCreator touchBarButtonWithImage:[NSImage imageNamed:NSImageNameLockLockedTemplate]
                                                 identifier:MPTouchBarItemIdentifierLock
                                                     target:self
                                                   selector:@selector(lock:)
                                         customizationLabel:NSLocalizedString(@"TOUCHBAR_LOCK_DATABASE","Touchbar button label for locking the database")];
  }
#pragma mark secondary/popover touchbar elements
  if([identifier isEqualToString:MPTouchBarItemIdentifierNewEntry]) {
    return [MPTouchBarButtonCreator touchBarButtonWithTitleAndImage:NSLocalizedString(@"TOUCHBAR_NEW_ENTRY","Touchbar button label for creating a new item")
                                                         identifier:MPTouchBarItemIdentifierNewEntry
                                                              image:[MPIconHelper icon:MPIconAddEntry]
                                                             target:self
                                                           selector:@selector(createEntry:)
                                                 customizationLabel:NSLocalizedString(@"TOUCHBAR_NEW_ENTRY","Touchbar button label for creating a new item")];
  }
  if([identifier isEqualToString:MPTouchBarItemIdentifierNewGroup]) {
    return [MPTouchBarButtonCreator touchBarButtonWithTitleAndImage:NSLocalizedString(@"TOUCHBAR_NEW_GROUP","Touchbar button label for creating a new group")
                                                         identifier:MPTouchBarItemIdentifierNewGroup
                                                              image:[MPIconHelper icon:MPIconAddFolder]
                                                             target:self
                                                           selector:@selector(createGroup:)
                                                 customizationLabel:NSLocalizedString(@"TOUCHBAR_NEW_GROUP","Touchbar button label for creating a new group")];
  }
  if([identifier isEqualToString:MPTouchBarItemIdentifierDelete]) {
    return [MPTouchBarButtonCreator touchBarButtonWithTitleAndImageAndColor:NSLocalizedString(@"TOUCHBAR_DELETE","Touchbar button label for deleting elements")
                                                                 identifier:MPTouchBarItemIdentifierDelete
                                                                      image:[MPIconHelper icon:MPIconTrash]
                                                                      color:NSColor.systemRedColor
                                                                     target:self
                                                                   selector:@selector(delete:)
                                                         customizationLabel:NSLocalizedString(@"TOUCHBAR_DELETE","Touchbar button label for deleting elements")];
  }
  return nil;
}

- (void)focusSearchField {
  [self.window makeFirstResponder:self.searchField];
}

@end
