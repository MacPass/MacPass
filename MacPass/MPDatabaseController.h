//
//  MPDatabaseController.h
//  MacPass
//
//  Created by michael starke on 13.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

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

typedef enum{
  MPDatabaseVersion1,
  MPDatabaseVersion2
} MPDatabaseVersion;

@class MPDatabaseDocument;

@interface MPDatabaseController : NSObject

@property (retain, readonly, nonatomic) MPDatabaseDocument *database;

+ (MPDatabaseController *)defaultController;

- (MPDatabaseDocument *)createDatabase:(MPDatabaseVersion )version password:(NSString *)password keyfile:(NSURL *)key;
- (MPDatabaseDocument *)openDatabase:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key;

@end
