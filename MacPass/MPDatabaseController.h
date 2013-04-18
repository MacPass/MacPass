//
//  MPDatabaseController.h
//  MacPass
//
//  Created by michael starke on 13.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPDatabaseVersion.h"

/*
 Notification is posted, when a database is loaded
 The userInfo dictionary contains the following keys
 MPDatabaseControllerDatabaseKey
 */
APPKIT_EXTERN NSString *const MPDatabaseControllerDidLoadDatabaseNotification;
APPKIT_EXTERN NSString *const MPDatabaseControllerDidCloseDatabaseNotification;
/*
 Database loaded or closed
 */
APPKIT_EXTERN NSString *const MPDatabaseControllerDatabaseKey;


@class MPDatabaseDocument;

@interface MPDatabaseController : NSObject

@property (retain, readonly, nonatomic) MPDatabaseDocument *database;

+ (MPDatabaseController *)defaultController;
+ (BOOL)hasOpenDatabase;

- (MPDatabaseDocument *)createDatabase:(MPDatabaseVersion)version password:(NSString *)password keyfile:(NSURL *)key;
- (MPDatabaseDocument *)openDatabase:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key;
- (MPDatabaseDocument *)newDatabaseAtURL:(NSURL *)url databaseVersion:(MPDatabaseVersion)version password:(NSString *)password keyfile:(NSURL *)key;

@end
