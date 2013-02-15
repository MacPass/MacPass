//
//  MPDatabaseController.h
//  MacPass
//
//  Created by michael starke on 13.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPDatabaseDocument;

typedef enum{
  MPDatabaseVersion1,
  MPDatabaseVersion2
} MPDatabaseVersion;


@interface MPDatabaseController : NSObject

@property (retain, readonly) MPDatabaseDocument *database;

+ (MPDatabaseController *)defaultController;

- (MPDatabaseDocument *)createDatabase:(MPDatabaseVersion )version password:(NSString *)password keyfile:(NSURL *)key;
- (MPDatabaseDocument *)openDatabase:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key;

@end
