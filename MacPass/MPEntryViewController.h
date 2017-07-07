//
//  MPEntryViewController.h
//  MacPass
//
//  Created by michael starke on 18.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"
#import "MPContextBarViewController.h"
#import "MPTargetNodeResolving.h"

APPKIT_EXTERN NSString *const MPEntryTableUserNameColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableTitleColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTablePasswordColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableParentColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableURLColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableNotesColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableAttachmentColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableModfiedColumnIdentifier;

typedef NS_ENUM(NSUInteger, MPDisplayMode) {
  MPDisplayModeEntries,
  MPDisplayModeSearchResults,
  MPDisplayModeHistory
};

@class KPKEntry;
@class MPDocumentWindowController;
@class MPDocument;

@interface MPEntryViewController : MPViewController <NSTableViewDelegate, MPTargetNodeResolving>

@property (weak,readonly) NSTableView *entryTable;
@property (readonly, strong) NSArrayController *entryArrayController;
@property (readonly, assign) MPDisplayMode displayMode;

/* Call this after all view controllers are loaded */
- (void)registerNotificationsForDocument:(MPDocument *)document;

/* Copy/Paste */
- (IBAction)copyUsername:(id)sender;
- (IBAction)copyPassword:(id)sender;
- (IBAction)copyCustomAttribute:(id)sender;
- (IBAction)copyURL:(id)sender;
- (IBAction)openURL:(id)sender;

/* More Actions */
- (IBAction)delete:(id)sender;
- (IBAction)revertToHistoryEntry:(id)sender;

@end

