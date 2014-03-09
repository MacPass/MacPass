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
#import "MPPasswordEditWindowController.h"
#import "MPConstants.h"
#import "MPSettingsHelper.h"
#import "MPDocumentWindowDelegate.h"

#import "MPContextToolbarButton.h"
#import "KPKTree.h"
#import "KPKCompositeKey.h"

typedef NS_ENUM(NSUInteger, MPAlertContext) {
  MPAlertLossySaveWarning,
};

typedef void (^MPPasswordChangedBlock)(void);

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

@property (nonatomic, copy) MPPasswordChangedBlock passwordChangedBlock;

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
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark View Handling
- (void)windowDidLoad {
  [super windowDidLoad];
  
  [[self window] setDelegate:self.documentWindowDelegate];
  [[self window] registerForDraggedTypes:@[NSURLPboardType]];
  
  MPDocument *document = [self document];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didRevertDocument:) name:MPDocumentDidRevertNotifiation object:document];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showEntries) name:MPDocumentDidUnlockDatabaseNotification object:document];
  
  [_entryViewController regsiterNotificationsForDocument:document];
  [_inspectorViewController regsiterNotificationsForDocument:document];
  [_outlineViewController regsiterNotificationsForDocument:document];
  [_toolbarDelegate registerNotificationsForDocument:document];
  
  
  
  _toolbar = [[NSToolbar alloc] initWithIdentifier:@"MainWindowToolbar"];
  [_toolbar setAutosavesConfiguration:YES];
  [self.toolbar setAllowsUserCustomization:YES];
  [self.toolbar setDelegate:self.toolbarDelegate];
  [self.window setToolbar:self.toolbar];
  self.toolbarDelegate.toolbar = _toolbar;
  
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
  
  if(document.encrypted) {
    [self showPasswordInput];
  }
  else {
    [self showEntries];
  }
  
  [_splitView setAutosaveName:@"SplitView"];
}

- (NSSearchField *)searchField {
  return self.toolbarDelegate.searchField;
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

#pragma mark MPDocument notifications
- (void)_didRevertDocument:(NSNotification *)notification {
  [self.outlineViewController clearSelection];
  [self showPasswordInput];
}

#pragma mark Actions
- (void)saveDocument:(id)sender {
  self.passwordChangedBlock = nil;
  MPDocument *document = [self document];
  NSString *fileType = [document fileType];
  /* we did open as legacy */
  if([fileType isEqualToString:MPLegacyDocumentUTI]) {
    if(document.tree.minimumVersion != KPKLegacyVersion) {
      NSAlert *alert = [[NSAlert alloc] init];
      [alert setAlertStyle:NSWarningAlertStyle];
      [alert setMessageText:NSLocalizedString(@"WARNING_ON_LOSSY_SAVE", "")];
      [alert setInformativeText:NSLocalizedString(@"WARNING_ON_LOSSY_SAVE_DESCRIPTION", "Informative Text displayed when saving woudl yield data loss")];
      [alert addButtonWithTitle:NSLocalizedString(@"SAVE_LOSSY", "Save lossy")];
      [alert addButtonWithTitle:NSLocalizedString(@"CHANGE_FORMAT", "")];
      [alert addButtonWithTitle:NSLocalizedString(@"CANCEL", "Cancel")];
      
      //[[alert buttons][2] setKeyEquivalent:[NSString stringWithFormat:@"%c", 0x1b]];
      [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(_dataLossOnSaveAlertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
      return;
    }
  }
  else if(!document.compositeKey) {
    __weak MPDocument *weakDocument = [self document];
    self.passwordChangedBlock = ^void(void){[weakDocument saveDocument:sender];};
    [self editPassword:sender];
    return;
  }
  /* All set and good ready to save */
  [[self document] saveDocument:sender];
}
- (void)saveDocumentAs:(id)sender {
  self.passwordChangedBlock = nil;
  MPDocument *document = [self document];
  if(!document.compositeKey) {
    __weak MPDocument *weakDocument = [self document];
    self.passwordChangedBlock = ^void(void){[weakDocument saveDocumentAs:sender];};
    [self editPassword:sender];
    return;
  }
  [[self document] saveDocumentAs:sender];
}

- (void)exportAsXML:(id)sender {
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  MPDocument *document = [self document];
  [savePanel setNameFieldStringValue:[document displayName]];
  [savePanel setAllowsOtherFileTypes:YES];
  [savePanel setAllowedFileTypes:@[(id)kUTTypeXML]];
  [savePanel setCanSelectHiddenExtension:YES];
  [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
    if(result == NSFileHandlingPanelOKButton) {
      [document writeXMLToURL:savePanel.URL];
    }
  }];
}

- (void)importFromXML:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  MPDocument *document = [self document];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setCanChooseFiles:YES];
  [openPanel setAllowedFileTypes:@[(id)kUTTypeXML]];
  [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
    if(result == NSFileHandlingPanelOKButton) {
      [document readXMLfromURL:openPanel.URL];
      [self.outlineViewController showOutline];
    }
  }];
}

- (void)showPasswordInput {
  if(!self.passwordInputController) {
    self.passwordInputController = [[MPPasswordInputController alloc] init];
  }
  [self _setContentViewController:self.passwordInputController];
  [self.passwordInputController requestPassword];
}

- (void)editPassword:(id)sender {
  if(!self.passwordEditWindowController) {
    self.passwordEditWindowController = [[MPPasswordEditWindowController alloc] initWithDocument:[self document]];
    self.passwordEditWindowController.delegate = self;
  }
  /* Disallow empty password if we want to save afterwards, otherwise the dialog keeps poping up */
  self.passwordEditWindowController.allowsEmptyPasswordOrKey = (self.passwordChangedBlock == nil);
  [NSApp beginSheet:[self.passwordEditWindowController window] modalForWindow:[self window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
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
  [self showPasswordInput];
  [document lockDatabase:sender];
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

- (void)focusEntries:(id)sender {
  [[self window] makeFirstResponder:[self.entryViewController reconmendedFirstResponder]];
}

- (void)focusGroups:(id)sender {
  [[self window] makeFirstResponder:[self.outlineViewController reconmendedFirstResponder]];
}

- (void)focusInspector:(id)sender {
  [[self window] makeFirstResponder:[self.inspectorViewController reconmendedFirstResponder]];
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
  [_entryViewController updateResponderChain];
  [_inspectorViewController updateResponderChain];
  [_outlineViewController updateResponderChain];
  [_outlineViewController showOutline];
  
  /* Restore the State the inspector view was in before the view change */
  if(removeInspector) {
    [inspectorView removeFromSuperview];
  }
  [contentView layoutSubtreeIfNeeded];
}

#pragma mark Validation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  return ([[self document] validateMenuItem:menuItem]);
}

#pragma mark MPPasswordEditWindowDelegate
- (void)didFinishPasswordEditing:(BOOL)changedPasswordOrKey {
  if(changedPasswordOrKey && self.passwordChangedBlock) {
    self.passwordChangedBlock();
  }
  self.passwordChangedBlock = nil;
}

#pragma mark Alert Delegate
- (void)_dataLossOnSaveAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
  
  switch(returnCode) {
    case NSAlertFirstButtonReturn:
      /* Save lossy */
      [[self document] saveDocument:nil];
      return;
      
    case NSAlertSecondButtonReturn:
      /* Change Format */
      //[[self document] setFileType:[MPDocument fileTypeForVersion:KPKXmlVersion]];
      [[alert window] orderOut:nil];
      [[self document] saveDocumentAs:nil];
      return;
      
    case NSAlertThirdButtonReturn:
    default:
      return; // Cancel or unknown
  }
}
- (void)_showDatabaseSetting:(MPDatabaseSettingsTab)tab {
  if(!self.documentSettingsWindowController) {
    _documentSettingsWindowController = [[MPDatabaseSettingsWindowController alloc] initWithDocument:[self document]];
  }
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
