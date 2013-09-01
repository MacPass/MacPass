//
//  MPMainWindowController.h
//  MacPass
//
//  Created by Michael Starke on 24.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MPViewController;
@class MPEntryViewController;
@class MPInspectorViewController;
@class MPPasswordInputController;
@class MPOutlineViewController;

@interface MPDocumentWindowController : NSWindowController

@property (readonly, strong) MPPasswordInputController *passwordInputController;
@property (readonly, strong) MPEntryViewController *entryViewController;
@property (readonly, strong) MPOutlineViewController *outlineViewController;
@property (readonly, strong) MPInspectorViewController *inspectorViewController;

/**
 @param action The action that should be validatet
 @param item The item that the action affects. Pass nil to fall back for default item
 @returns YES if the action is valid, NO otherwise
 */
- (BOOL)validateAction:(SEL)action forItem:(id)item;

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

@end
