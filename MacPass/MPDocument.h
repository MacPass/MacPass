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

APPKIT_EXTERN NSString *const MPDocumentDidLockDatabaseNotification;
APPKIT_EXTERN NSString *const MPDocumentDidUnlockDatabaseNotification;

APPKIT_EXTERN NSString *const MPDocumentEntryKey;
APPKIT_EXTERN NSString *const MPDocumentGroupKey;

@class KPKGroup;
@class KPKEntry;
@class KPKTree;
@class KPKBinary;
@class KPKAttribute;

@interface MPDocument : NSDocument

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
- (BOOL)unlockWithPassword:(NSString *)password keyFileURL:(NSURL *)keyFileURL error:(NSError *__autoreleasing*)error;

#pragma mark Data Lookup
/**
 *  Finds an entry with the given UUID. If none is found, nil is returned
 *  @param uuid The UUID for the searched Entry
 *  @return enty, matching the UUID, nil if none was found
 */
- (KPKEntry *)findEntry:(NSUUID *)uuid;
/**
 *  Finds the group with the given UUID in this document. If none if found, nil is returned
 *  @param uuid The UUID of the searched group
 *  @return matching group, nil if none was found
 */
- (KPKGroup *)findGroup:(NSUUID *)uuid;

- (void)useGroupAsTrash:(KPKGroup *)group;
- (void)useGroupAsTemplate:(KPKGroup *)group;
/**
 *  Determines, whether the given item is inside the trash.
 *  The trash group itself is not considered as trashed.
 *  Hence when sending this message with the trash group as item, NO is returned
 *  @param item Item to test if trashed or not
 *  @return YES, if the item is inside the trash, NO otherwise (and if item is trash group)
 */
- (BOOL)isItemTrashed:(id)item;

- (void)writeXMLToURL:(NSURL *)url;

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