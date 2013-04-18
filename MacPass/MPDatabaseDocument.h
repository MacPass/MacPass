//
//  MPDocument.h
//  MacPass
//
//  Created by Michael Starke on 21.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPDatabaseVersion.h"

APPKIT_EXTERN NSString *const MPDidLoadDatabaseNotification;
APPKIT_EXTERN NSString *const MPDatabaseDocumentDocumentKey;

@class KdbPassword;
@class KdbGroup;
@class KdbEntry;

@interface MPDatabaseDocument : NSObject

@property (assign, readonly) KdbGroup *root;
@property (retain, readonly) NSURL *file;
@property (nonatomic,retain) NSString *password;
@property (nonatomic, retain) NSURL *key;
@property (assign, readonly) MPDatabaseVersion version;

+ (id)documentWithFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key;
+ (id)documentWithNewDatabase:(MPDatabaseVersion)version;
+ (id)newDocumentAtURL:(NSURL *)url databaseVersion:(MPDatabaseVersion)dbversion password:(NSString *)password keyfile:(NSURL *)key;
- (id)initWithFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key;
- (id)initWithNewDatabase:(MPDatabaseVersion)version;
- (id)initNewDocumentAtURL:(NSURL *)url databaseVersion:(MPDatabaseVersion)dbversion password:(NSString *)password keyfile:(NSURL *)key;
/*
 Saves the current database to the filesystem
 Tries to use the stored password and file path
 
 If self.file and self.password aren't valid, the save does not get executed
 */
- (BOOL)save;
- (BOOL)saveAsFile:(NSURL *)file withPassword:(NSString *)password keyfile:(NSURL *)key;

- (KdbGroup *)createGroup:(KdbGroup *)parent;
- (KdbEntry *)createEntry:(KdbGroup *)parent;


@end
