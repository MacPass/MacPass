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

@class KdbPassword;
@class KdbGroup;

@interface MPDatabaseDocument : NSObject

@property (retain, readonly) KdbGroup *root;
@property (retain, readonly) NSURL *file;
@property (retain, readonly) KdbPassword *password;

+ (id)documentWithFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key;
- (id)initWithFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key;
/*
 Saves the current database to the filesystem
 Tries to use the stored password and file path
 
 If self.file and self.password aren't valid, the save does not get executed
 */
- (BOOL)save;
- (BOOL)saveAsFile:(NSURL *)file withPassword:(NSString *)password keyfile:(NSURL *)key;

@end
