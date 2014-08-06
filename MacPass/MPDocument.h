//
//  MPDocument.h
//  MacPass
//
//  Created by Michael Starke on 08.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Cocoa/Cocoa.h>
#import "KPKVersion.h"

APPKIT_EXTERN NSString *const MPDocumentDidAddGroupNotification;
APPKIT_EXTERN NSString *const MPDocumentDidRevertNotifiation;

APPKIT_EXTERN NSString *const MPDocumentDidLockDatabaseNotification;
APPKIT_EXTERN NSString *const MPDocumentDidUnlockDatabaseNotification;

FOUNDATION_EXTERN NSString *const MPDocumentCurrentItemChangedNotification;
FOUNDATION_EXTERN NSString *const MPDocumentItemAddedNotification;

APPKIT_EXTERN NSString *const MPDocumentEntryKey;
APPKIT_EXTERN NSString *const MPDocumentGroupKey;

@class KPKGroup;
@class KPKEntry;
@class KPKTree;
@class KPKBinary;
@class KPKAttribute;
@class KPKCompositeKey;
@class KPKNode;
@class MPEditSession;

typedef NS_OPTIONS(NSUInteger, MPEntrySearchFlags) {
  MPEntrySearchNone            = 0,
  MPEntrySearchUrls            = (1<<0),
  MPEntrySearchUsernames       = (1<<1),
  MPEntrySearchTitles          = (1<<2),
  MPEntrySearchPasswords       = (1<<3),
  MPEntrySearchNotes           = (1<<4),
  MPEntrySearchAllAttributes   = (1<<5),
  MPEntrySearchDoublePasswords = (1<<6), // Unused in GUI for now
  MPEntrySearchAllFlags        = (MPEntrySearchDoublePasswords |
                                  MPEntrySearchNotes |
                                  MPEntrySearchPasswords |
                                  MPEntrySearchTitles |
                                  MPEntrySearchUrls |
                                  MPEntrySearchUsernames |
                                  MPEntrySearchAllAttributes )
};

@interface MPDocument : NSDocument

@property (nonatomic, readonly, assign) BOOL encrypted;

@property (strong, readonly, nonatomic) KPKTree *tree;
@property (nonatomic, weak, readonly) KPKGroup *root;
@property (nonatomic, weak) KPKGroup *trash;
@property (nonatomic, readonly) BOOL useTrash;
@property (nonatomic, weak) KPKGroup *templates;

@property (nonatomic, strong, readonly) KPKCompositeKey *compositeKey;

@property (assign, readonly, getter = isReadOnly) BOOL readOnly;
@property (nonatomic, readonly, assign) KPKVersion versionForFileType;

/*
 State (active group/entry)
 */
@property (nonatomic, weak) KPKEntry *selectedEntry;
@property (nonatomic, weak) KPKGroup *selectedGroup;
@property (nonatomic, weak) KPKNode *selectedItem;

/*
 Search - see MPDocument+Search for further details
 */
@property (nonatomic, assign) MPEntrySearchFlags activeFlags;
@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, assign) BOOL hasSearch;
@property (nonatomic, strong) NSArray *searchResult;

/*
 Editing Session
 */
@property (nonatomic, strong) MPEditSession *editingSession;

+ (KPKVersion)versionForFileType:(NSString *)fileType;
+ (NSString *)fileTypeForVersion:(KPKVersion)version;

#pragma mark Lock/Decrypt
- (IBAction)lockDatabase:(id)sender;
/**
 *  Decrypts the databse with the given password and keyfile
 *
 *  @param password   The password to unlock the db with, can be nil. This is not the same as an empty stirng @""
 *  @param keyFileURL URL for the keyfile to use, can be nil
 *  @param error  Pointer to an NSError pointer of error reporting.
 *
 *  @return YES if the document was unlocked sucessfully, NO otherwise. Consult the error object for details
 */
- (BOOL)unlockWithPassword:(NSString *)password keyFileURL:(NSURL *)keyFileURL error:(NSError *__autoreleasing*)error;
/**
 *  Changes the password of the database. Some sanity checks are applied and the change is aborted if the new values arent valid
 *
 *  @param password   new password, can be nil
 *  @param keyFileURL new key URL can be nil
 *
 *  @return YES if the password was change, NO otherwise
 */
- (BOOL)changePassword:(NSString *)password keyFileURL:(NSURL *)keyFileURL;
/**
 *  Returns the suggest key URL for this document. This might be nil.
 *  If the user did disable remeberKeyFiles in the settings, this always returns nil
 *  Otherwise the preferences are searched to locate the last know key url for this document
 *
 *  @return The suggested key URL if one was found and the settings are allowing suggesting key locations
 */
- (NSURL *)suggestedKeyURL;

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
- (NSArray *)allEntries;
- (NSArray *)allGroups;

/**
 *  Determines, whether the given item is inside the trash.
 *  The trash group itself is not considered as trashed.
 *  Hence when sending this message with the trash group as item, NO is returned
 *  @param item Item to test if trashed or not
 *  @return YES, if the item is inside the trash, NO otherwise (and if item is trash group)
 */
- (BOOL)isItemTrashed:(id)item;

- (void)writeXMLToURL:(NSURL *)url;
- (void)readXMLfromURL:(NSURL *)url;

/* Undoable Intiialization of elements */
- (KPKGroup *)createGroup:(KPKGroup *)parent;
- (KPKEntry *)createEntry:(KPKGroup *)parent;
- (KPKAttribute *)createCustomAttribute:(KPKEntry *)entry;

- (void)deleteGroup:(KPKGroup *)group;
- (void)deleteEntry:(KPKEntry *)entry;

#pragma mark Actions
/**
 *  Empties the Trash group. Removing all Groups and Entries inside. This aciton is not undoable
 *  @param sender sender
 */
- (IBAction)emptyTrash:(id)sender;
/**
 *  Creates an Entry for a template. We assume the sender is an item, that contains a UUID as representedObject.
 *
 *  @param sender sender, that should respond to representedObject and return an NSUUID for the template to use
 */
- (IBAction)createEntryFromTemplate:(id)sender;

- (IBAction)cloneEntry:(id)sender;

- (IBAction)cloneEntryWithOptions:(id)sender;

@end
