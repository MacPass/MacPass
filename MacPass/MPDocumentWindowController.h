//
//  MPMainWindowController.h
//  MacPass
//
//  Created by Michael Starke on 24.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPPasswordEditWindowController.h"

@class MPViewController;
@class MPEntryViewController;
@class MPInspectorViewController;
@class MPPasswordInputController;
@class MPOutlineViewController;
@class MPToolbarDelegate;

@interface MPDocumentWindowController : NSWindowController <MPPasswordEditWindowDelegate>

@property (readonly, strong) MPPasswordInputController *passwordInputController;
@property (readonly, strong) MPEntryViewController *entryViewController;
@property (readonly, strong) MPOutlineViewController *outlineViewController;
@property (readonly, strong) MPInspectorViewController *inspectorViewController;
@property (readonly, strong) MPToolbarDelegate *toolbarDelegate;

- (void)showEntries;
- (void)showPasswordInput;
- (IBAction)performFindPanelAction:(id)sender;
- (IBAction)cancelSearch:(id)sender;

- (IBAction)saveDocument:(id)sender;

- (IBAction)editPassword:(id)sender;
- (IBAction)showDatabaseSettings:(id)sender;
- (IBAction)editTemplateGroup:(id)sender;
- (IBAction)editTrashGroup:(id)sender;

- (IBAction)exportAsXML:(id)sender;
- (IBAction)importFromXML:(id)sender;

- (IBAction)lock:(id)sender;

- (IBAction)createGroup:(id)sender;

#pragma mark View Actions
- (IBAction)toggleInspector:(id)sender;
- (IBAction)focusGroups:(id)sender;
- (IBAction)focusEntries:(id)sender;
- (IBAction)focusInspector:(id)sender;

#pragma mark MPPasswordEditWindowDelegater
- (void)didFinishPasswordEditing:(BOOL)changedPasswordOrKey;

@end
