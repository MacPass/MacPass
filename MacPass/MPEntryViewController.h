//
//  MPEntryViewController.h
//  MacPass
//
//  Created by michael starke on 18.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"
#import "MPContextBarViewController.h"

APPKIT_EXTERN NSString *const MPEntryTableUserNameColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableTitleColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTablePasswordColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableParentColumnIdentifier;
APPKIT_EXTERN NSString *const MPEntryTableURLColumnIdentifier;

/* Tags to determine what to copy */
typedef NS_ENUM( NSUInteger, MPCopyContentTypeTag) {
  MPCopyUsername,
  MPCopyPassword,
  MPCopyURL,
  MPCopyWholeEntry,
};

@class KPKEntry;
@class MPOutlineViewDelegate;
@class MPDocumentWindowController;
@class MPDocument;

@interface MPEntryViewController : MPViewController <NSTableViewDelegate>

@property (weak,readonly) NSTableView *entryTable;
@property (readonly, strong) NSArrayController *entryArrayController;

/* Call this after alle viewcontroller are loaded */
- (void)regsiterNotificationsForDocument:(MPDocument *)document;

/* Copy/Paste */
- (void)copyUsername:(id)sender;
- (void)copyPassword:(id)sender;
- (void)copyCustomAttribute:(id)sender;
- (void)copyURL:(id)sender;
- (void)openURL:(id)sender;

@end
