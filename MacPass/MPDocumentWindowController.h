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

@class KdbGroup;
@class KdbEntry;

APPKIT_EXTERN NSString *const MPCurrentItemChangedNotification;

@interface MPDocumentWindowController : NSWindowController <NSWindowDelegate>

@property (readonly, strong) MPPasswordInputController *passwordInputController;
@property (readonly, strong) MPEntryViewController *entryViewController;
@property (readonly, strong) MPOutlineViewController *outlineViewController;
@property (readonly, strong) MPInspectorViewController *inspectorViewController;


/* Holds the current item. That is either a KdbGroup or a KdbEntry */
@property (readonly, unsafe_unretained) id currentItem;
@property (readonly, unsafe_unretained) KdbGroup *currentGroup;
@property (readonly, unsafe_unretained) KdbEntry *currentEntry;

/**
 @param action The action that should be validatet
 @param item The item that the action affects. Pass nil to fall back for default item
 @returns YES if the action is valid, NO otherwise
 */
- (BOOL)validateAction:(SEL)action forItem:(id)item;

- (void)showEntries;
- (void)showPasswordInput;
- (void)performFindPanelAction:(id)sender;
- (IBAction)editPassword:(id)sender;
- (IBAction)showDatabaseSettings:(id)sender;
- (IBAction)exportDatabase:(id)sender;

- (IBAction)lock:(id)sender;

- (void)createGroup:(id)sender;
- (void)toggleInspector:(id)sender;

@end
