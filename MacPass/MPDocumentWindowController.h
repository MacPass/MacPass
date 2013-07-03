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
@class MPPasswordEditViewController;
@class MPPasswordInputController;
@class MPOutlineViewController;

@class KdbGroup;
@class KdbEntry;

APPKIT_EXTERN NSString *const MPCurrentItemChangedNotification;

@interface MPDocumentWindowController : NSWindowController <NSWindowDelegate>

@property (readonly, strong) MPPasswordInputController *passwordInputController;
@property (readonly, strong) MPPasswordEditViewController *passwordEditController;
@property (readonly, strong) MPEntryViewController *entryViewController;
@property (readonly, strong) MPOutlineViewController *outlineViewController;
@property (readonly, strong) MPInspectorViewController *inspectorViewController;


/* Holds the current item. That is either a KdbGroup or a KdbEntry */
@property (readonly, unsafe_unretained) id currentItem;
@property (readonly, unsafe_unretained) KdbGroup *currentGroup;
@property (readonly, unsafe_unretained) KdbEntry *currentEntry;


- (void)showEntries;
- (void)showPasswordInput;
- (void)performFindPanelAction:(id)sender;
- (IBAction)editPassword:(id)sender;
- (IBAction)showDocumentSettings:(id)sender;

- (void)lock:(id)sender;

- (void)createGroup:(id)sender;
- (void)toggleInspector:(id)sender;

@end
