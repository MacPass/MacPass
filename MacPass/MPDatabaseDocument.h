//
//  MPDocument.h
//  MacPass
//
//  Created by Michael Starke on 21.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

APPKIT_EXTERN NSString *const MPDidLoadDataBaseNotification;
APPKIT_EXTERN NSString *const MPDataBaseDocumentDocumentKey;

typedef enum {
  MPDatabaseVersion3,
  MPDatabaseVersion4
} MPDatabaseVersion;

@class KdbPassword;
@class KdbGroup;

@interface MPDatabaseDocument : NSObject

@property (retain, readonly) KdbGroup *root;
@property (retain, readonly) NSURL *file;
@property (nonatomic,retain) NSString *password;
@property (nonatomic, retain) NSURL *key;
@property (assign, readonly) MPDatabaseVersion version;

+ (id)documentWithFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key;
- (id)initWithFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key;
- (id)initWithNewDatabase:(MPDatabaseVersion)version;
/*
 Saves the current database to the filesystem
 Tries to use the stored password and file path
 
 If self.file and self.password aren't valid, the save does not get executed
 */
- (BOOL)save;
- (BOOL)saveAsFile:(NSURL *)file withPassword:(NSString *)password keyfile:(NSURL *)key;

@end
