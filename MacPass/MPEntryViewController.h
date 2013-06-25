//
//  MPEntryViewController.h
//  MacPass
//
//  Created by michael starke on 18.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

APPKIT_EXTERN NSString *const MPEntryTableUserNameColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableTitleColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTablePasswordColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableParentColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableURLColumnIdentifier;

APPKIT_EXTERN NSString *const MPDidChangeSelectedEntryNotification;

/* Tags to determine what to copy */
typedef enum {
  MPCopyUsername,
  MPCopyPassword,
  MPCopyURL,
  MPCopyWholeEntry,
} MPCopyContentTypeTag;

@class KdbGroup;
@class KdbEntry;
@class MPOutlineViewDelegate;
@class MPDocumentWindowController;

@interface MPEntryViewController : MPViewController <NSTableViewDelegate>

@property (readonly, assign, nonatomic) KdbEntry *selectedEntry;

@property (assign,readonly) NSTableView *entryTable;
@property (readonly, retain) NSArrayController *entryArrayController;
@property (nonatomic, retain) NSString *filter;


/* Call this after alle viewcontroller are loaded */
- (void)setupNotifications:(MPDocumentWindowController *)windowController;

/* Clear the Search filter*/
- (void)showFilter:(id)sender;
- (void)clearFilter:(id)sender;

/* Copy/Paste */
- (void)copyUsername:(id)sender;
- (void)copyPassword:(id)sender;
- (void)copyURL:(id)sender;
- (void)openURL:(id)sender;

/* Entry Handling*/
- (void)deleteNode:(id)sender;

@end
