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

@interface MPDocumentWindowController : NSWindowController <MPPasswordEditWindowDelegate>

@property (readonly, strong) MPPasswordInputController *passwordInputController;
@property (readonly, strong) MPEntryViewController *entryViewController;
@property (readonly, strong) MPOutlineViewController *outlineViewController;
@property (readonly, strong) MPInspectorViewController *inspectorViewController;

- (void)showEntries;
- (void)showPasswordInput;
- (void)performFindPanelAction:(id)sender;

- (IBAction)saveDocument:(id)sender;

- (IBAction)editPassword:(id)sender;
- (IBAction)showDatabaseSettings:(id)sender;
- (IBAction)editTemplateGroup:(id)sender;
- (IBAction)editTrashGroup:(id)sender;

- (IBAction)exportDatabase:(id)sender;

- (IBAction)lock:(id)sender;

- (void)createGroup:(id)sender;
- (void)toggleInspector:(id)sender;

#pragma mark MPPasswordEditWindowDelegater
- (void)didFinishPasswordEditing:(BOOL)changedPasswordOrKey;

@end
