//
//  MPDocument.h
//  MacPass
//
//  Created by Michael Starke on 08.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPDatabaseVersion.h"


APPKIT_EXTERN NSString *const MPDocumentDidAddGroupNotification;
APPKIT_EXTERN NSString *const MPDocumentWillDelteGroupNotification;
APPKIT_EXTERN NSString *const MPDocumentDidAddEntryNotification;
APPKIT_EXTERN NSString *const MPDocumentWillDeleteEntryNotification;
APPKIT_EXTERN NSString *const MPDocumentDidRevertNotifiation;

APPKIT_EXTERN NSString *const MPDocumentEntryKey;
APPKIT_EXTERN NSString *const MPDocumentGroupKey;

@class KdbGroup;
@class KdbEntry;
@class KdbTree;
@class UUID;
@class Binary;
@class BinaryRef;

@interface MPDocument : NSDocument

/* true, if password and/or keyfile are set */
@property (assign, readonly, getter = isSecured) BOOL secured;
/* true, if lock screen is present (no phyiscal locking) */
@property (assign, getter = isLocked) BOOL locked;
/* true, if document is loaded and decrypted (tree is loaded) */
@property (assign, readonly, getter = isDecrypted) BOOL decrypted;
@property (retain, readonly) KdbTree *tree;
@property (assign, readonly, nonatomic) KdbGroup *root;
@property (nonatomic,retain) NSString *password;
@property (nonatomic, retain) NSURL *key;
@property (assign, readonly) MPDatabaseVersion version;

- (id)initWithVersion:(MPDatabaseVersion)version;
- (BOOL)decryptWithPassword:(NSString *)password keyFileURL:(NSURL *)keyFileURL;

#pragma mark Data Lookup
/*
 Returns the entry for the given UUID, nil if none was found
 */
- (KdbEntry *)findEntry:(UUID *)uuid;
/*
 Return the Binary for the given BinaryRef. nil if none was found
 */
- (Binary *)binaryForRef:(BinaryRef *)binaryRef;


#pragma mark Data Manipulation
/* Undoable Intiialization of elements */
- (KdbGroup *)createGroup:(KdbGroup *)parent;
- (KdbEntry *)createEntry:(KdbGroup *)parent;

/*
 All non-setter undoable actions
*/

- (void)moveGroup:(KdbGroup *)group toGroup:(KdbGroup *)target index:(NSInteger)index;
- (BOOL)group:(KdbGroup *)group isMoveableToGroup:(KdbGroup *)target;
- (void)moveEntry:(KdbEntry *)entry toGroup:(KdbGroup *)target index:(NSInteger)index;

- (void)group:(KdbGroup *)group addEntry:(KdbEntry *)entry;
- (void)group:(KdbGroup *)group addGroup:(KdbGroup *)aGroup;
- (void)group:(KdbGroup *)group removeEntry:(KdbEntry *)entry;
- (void)group:(KdbGroup *)group removeGroup:(KdbGroup *)aGroup;




@end
