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
@class MPInspectorTabViewController;
@class MPPasswordEditViewController;
@class MPPasswordInputController;
@class MPOutlineViewController;
@class MPCreationViewController;


@interface MPDocumentWindowController : NSWindowController

@property (readonly, retain) MPPasswordInputController *passwordInputController;
@property (readonly, retain) MPPasswordEditViewController *passwordEditController;
@property (readonly, retain) MPEntryViewController *entryViewController;
@property (readonly, retain) MPOutlineViewController *outlineViewController;
@property (readonly, retain) MPInspectorTabViewController *inspectorTabViewController;
@property (readonly, retain) MPCreationViewController *creationViewController;

- (void)showEntries;
- (void)showPasswordInput;
- (void)performFindPanelAction:(id)sender;
- (void)clearOutlineSelection:(id)sender;
- (IBAction)editPassword:(id)sender;
/*
 Clears the Search filter
 */
- (void)toggleInspector:(id)sender;

@end
