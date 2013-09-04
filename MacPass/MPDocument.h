//
//  MPDocument.h
//  MacPass
//
//  Created by Michael Starke on 08.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KPKVersion.h"

APPKIT_EXTERN NSString *const MPDocumentDidAddGroupNotification;
APPKIT_EXTERN NSString *const MPDocumentDidRevertNotifiation;

APPKIT_EXTERN NSString *const MPDocumentEntryKey;
APPKIT_EXTERN NSString *const MPDocumentGroupKey;

/*
 APPKIT_EXTERN NSString *const MPDocumentDidChangeCurrentItemNotification;
APPKIT_EXTERN NSString *const MPDocumentDidChangeCurrentGroupNotication;
APPKIT_EXTERN NSString *const MPDocumnetDidChangeCurrentEntryNotification;
*/

@class KPKGroup;
@class KPKEntry;
@class KPKTree;
@class KPKBinary;
@class KPKAttribute;

@interface MPDocument : NSDocument

/* true, if password and/or keyfile are set */
@property (assign, readonly) BOOL hasPasswordOrKey;
@property (nonatomic, readonly, assign) BOOL encrypted;

@property (strong, readonly, nonatomic) KPKTree *tree;
@property (weak, readonly, nonatomic) KPKGroup *root;
@property (weak, readonly) KPKGroup *trash;
@property (weak, readonly) KPKGroup *templates;

@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) NSURL *key;

@property (assign, readonly, getter = isReadOnly) BOOL readOnly;
@property (nonatomic, readonly, assign) KPKVersion versionForFileType;

/*
 State (active group/entry)
 */
@property (nonatomic, weak) KPKEntry *selectedEntry;
@property (nonatomic, weak) KPKGroup *selectedGroup;
@property (nonatomic, weak) id selectedItem;


+ (KPKVersion)versionForFileType:(NSString *)fileType;
+ (NSString *)fileTypeForVersion:(KPKVersion)version;

#pragma mark Lock/Decrypt
- (void)lockDatabase:(id)sender;
- (BOOL)unlockWithPassword:(NSString *)password keyFileURL:(NSURL *)keyFileURL;

#pragma mark Data Lookup
/*
 Returns the entry for the given UUID, nil if none was found
 */
- (KPKEntry *)findEntry:(NSUUID *)uuid;
- (KPKGroup *)findGroup:(NSUUID *)uuid;

- (void)useGroupAsTrash:(KPKGroup *)group;
- (void)useGroupAsTemplate:(KPKGroup *)group;

- (BOOL)isItemTrashed:(id)item;

#pragma mark Export
- (void)writeXMLToURL:(NSURL *)url;

#pragma mark Undo Data Manipulation
/* Undoable Intiialization of elements */
- (KPKGroup *)createGroup:(KPKGroup *)parent;
- (KPKEntry *)createEntry:(KPKGroup *)parent;
- (KPKAttribute *)createCustomAttribute:(KPKEntry *)entry;

- (void)deleteGroup:(KPKGroup *)group;
- (void)deleteEntry:(KPKEntry *)entry;

- (IBAction)emptyTrash:(id)sender;
- (IBAction)createEntryFromTemplate:(id)sender;
@end

@interface MPDocument (Attachments)

- (void)addAttachment:(NSURL *)location toEntry:(KPKEntry *)anEntry;

@end