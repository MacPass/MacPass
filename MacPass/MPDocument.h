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
#import <KeePassKit/KeePassKit.h>
#import "MPEntrySearchContext.h"
#import "MPTargetNodeResolving.h"
#import "MPModelChangeObserving.h"

/**
 *  Posted when a new group was added to the document.
 *  This is only posted when the user caused this by adding.
 *  Undo/Redo will not cause this notification to be reposted
 *  The userInfo dictionary contains the added group at MPDocumentGroupKey
 */
FOUNDATION_EXPORT NSString *const MPDocumentDidAddGroupNotification;
/**
 *  Posted when the user has added a new entry to the document.
 *  Undo/redo will not cause this notification to be reposted.
 *  The userInfo dictionary contains the added entry at MPDocumentEntryKey
 */
FOUNDATION_EXPORT NSString *const MPDocumentDidAddEntryNotification;
FOUNDATION_EXPORT NSString *const MPDocumentDidRevertNotifiation;

FOUNDATION_EXPORT NSString *const MPDocumentDidLockDatabaseNotification;
FOUNDATION_EXPORT NSString *const MPDocumentDidUnlockDatabaseNotification;

FOUNDATION_EXPORT NSString *const MPDocumentCurrentItemChangedNotification;

/**
 *  Posted whenever a model change is initated via the user. This is mainly to broadcast changes
 *  to an entry done via the ui throuhgout the app.
 */
FOUNDATION_EXPORT NSString *const MPDocumentWillChangeModelPropertyNotification;
FOUNDATION_EXPORT NSString *const MPDocumentDidChangeModelPropertyNotification;

/* Keys used in userInfo NSDictionaries on notifications */
FOUNDATION_EXPORT NSString *const MPDocumentEntryKey;
FOUNDATION_EXPORT NSString *const MPDocumentGroupKey;

@class KPKGroup;
@class KPKEntry;
@class KPKTree;
@class KPKBinary;
@class KPKAttribute;
@class KPKCompositeKey;
@class KPKNode;

@interface MPDocument : NSDocument <MPTargetNodeResolving, MPModelChangeObserving>

@property (nonatomic, readonly, assign) BOOL encrypted;
@property (nonatomic, readonly, assign) NSUInteger unlockCount; // Amount of times the Document was unlocked;

@property (strong, readonly, nonatomic) KPKTree *tree;
@property (nonatomic, weak, readonly) KPKGroup *root;
@property (nonatomic, weak) KPKGroup *trash;
@property (nonatomic, weak) KPKGroup *templates;

@property (nonatomic, strong, readonly) KPKCompositeKey *compositeKey;

@property (assign, readonly, getter = isReadOnly) BOOL readOnly;
@property (atomic, assign) BOOL shouldSaveOnLock;
@property (nonatomic, readonly, assign) KPKDatabaseFormat formatForFileType;

/*
 State (active group/entry)
 */

@property (nonatomic, copy, readonly) NSArray<KPKNode *> *selectedNodes;
@property (nonatomic, copy) NSArray<KPKGroup *> *selectedGroups;
@property (nonatomic, copy) NSArray<KPKEntry *> *selectedEntries;


/*
 Search - see MPDocument+Search for further details
 
 FIXME: Document is pinned to mode bases search. Wrong design!
 */
@property (nonatomic, readonly) BOOL hasSearch;
@property (nonatomic, copy) MPEntrySearchContext *searchContext;
@property (nonatomic, strong, readonly) NSArray *searchResult;
@property (nonatomic, weak) KPKEntry *historyEntry;

+ (KPKDatabaseFormat)formatForFileType:(NSString *)fileType;
+ (NSString *)fileTypeForVersion:(KPKDatabaseFormat)format;

#pragma mark Lock/Decrypt
- (IBAction)lockDatabase:(id)sender;
/**
 *  Decrypts the database with the given password and keyfile
 *
 *  @param password   The password to unlock the db with, can be nil. This is not the same as an empty string @""
 *  @param keyFileURL URL for the keyfile to use, can be nil
 *  @param error  Pointer to an NSError pointer of error reporting.
 *
 *  @return YES if the document was unlocked sucessfully, NO otherwise. Consult the error object for details
 */
- (BOOL)unlockWithPassword:(NSString *)password keyFileURL:(NSURL *)keyFileURL error:(NSError *__autoreleasing*)error;
/**
 *  Changes the password of the database. Some sanity checks are applied and the change is aborted if the new values aren't valid
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
 *  @return entry, matching the UUID, nil if none was found
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

- (BOOL)shouldEnforcePasswordChange;
- (BOOL)shouldRecommendPasswordChange;

- (void)importTree:(KPKTree *)tree;
- (void)writeXMLToURL:(NSURL *)url;
- (void)readXMLfromURL:(NSURL *)url;
- (void)mergeWithContentsFromURL:(NSURL *)url key:(KPKCompositeKey *)key;

/* Undoable Intiialization of elements */
- (KPKGroup *)createGroup:(KPKGroup *)parent;
- (KPKEntry *)createEntry:(KPKGroup *)parent;
- (KPKAttribute *)createCustomAttribute:(KPKEntry *)entry;

- (void)deleteNode:(KPKNode *)node;
- (void)duplicateEntryWithOptions:(KPKCopyOptions)options;

#pragma mark Actions
/**
 *  Empties the Trash group. Removing all Groups and Entries inside. This action is not undo-able
 *  @param sender sender
 */
- (IBAction)emptyTrash:(id)sender;
/**
 *  Creates an Entry for a template. We assume the sender is an item, that contains a UUID as representedObject.
 *
 *  @param sender sender, that should respond to representedObject and return an NSUUID for the template to use
 */
- (IBAction)createEntryFromTemplate:(id)sender;
- (IBAction)duplicateEntry:(id)sender;
- (IBAction)duplicateGroup:(id)sender;

@end

@interface MPDocument (Attachments)

- (void)addAttachment:(NSURL *)location toEntry:(KPKEntry *)anEntry;

@end

#pragma mark -
#pragma mark Autotype

@interface MPDocument (Autotype)

/**
 *  Tests the given item for a possible wrong autotype format
 *  MacPass 0.4 and 0.4.1 did store wrong Autotype sequences and thus mangled database files
 *
 *  @param item Item to test for malformation. Allowed Items are KPKNode, KPKEntry, KPKGroup and KPKAutotype
 *
 *  @return YES if the given item is considered a possible candiate. NO in all other cases
 */
+ (BOOL)isCandidateForMalformedAutotype:(id)item;

/**
 *  Returns an NSArray containing all Autotype Contexts that match the given window title.
 *  If no entry is set, all entries in the document will be searched
 *
 *  @param windowTitle Window title to search matches for
 *  @param entry       Entry to use for lookup. If nil lookup will be performed in complete document
 *
 *  @return NSArray of MPAutotypeContext objects matching the window title.
 */
- (NSArray *)autotypContextsForWindowTitle:(NSString *)windowTitle preferredEntry:(KPKEntry *)entryOrNil;
/**
 *  Checks if the document has malformed autotype items
 *
 *  @return YES if any malformed items are found
 */
- (BOOL)hasMalformedAutotypeItems;

- (NSArray *)malformedAutotypeItems;

@end

#pragma mark -
#pragma mark History Browsing

/**
 *  Posted by the document to signal a reqest for history display.
 *  the userInfo dictionary has one key MPDocumentEntryKey with the entry to display the history for
 */
FOUNDATION_EXPORT NSString *const MPDocumentShowEntryHistoryNotification;
FOUNDATION_EXPORT NSString *const MPDocumentHideEntryHistoryNotification;

@interface MPDocument (History)

- (IBAction)showEntryHistory:(id)sender;
- (IBAction)hideEntryHistory:(id)sender;
- (IBAction)revertEntry:(KPKEntry *)entry toEntry:(KPKEntry *)historyEntry;

@end

#pragma mark -
#pragma mark Search

FOUNDATION_EXTERN NSString *const MPDocumentDidEnterSearchNotification;
FOUNDATION_EXTERN NSString *const MPDocumentDidChangeSearchFlags;
FOUNDATION_EXTERN NSString *const MPDocumentDidExitSearchNotification;
/**
 *  Posted by the document, when the search results have been updated. This is only called when searching.
 *  If the search is exited, it will be notified by MPDocumentDidExitSearchNotification
 *  The userInfo dictionary has one key kMPDocumentSearchResultsKey with an NSArray of KPKEntries matching the search.
 */
FOUNDATION_EXTERN NSString *const MPDocumentDidChangeSearchResults;

/* keys used in userInfo dictionaries on notifications */
FOUNDATION_EXTERN NSString *const kMPDocumentSearchResultsKey;

@interface MPDocument (Search)
- (IBAction)perfromCustomSearch:(id)sender;
- (void)enterSearchWithContext:(MPEntrySearchContext *)context;

/* Should be called by the NSSearchTextField to update the search string */
- (IBAction)updateSearch:(id)sender;
/* exits searching mode */
- (IBAction)exitSearch:(id)sender;
/* called by the filter toggle buttons */
- (IBAction)toggleSearchFlags:(id)sender;

@end


