//
//  MPDatabaseCreation.m
//  MacPass
//
//  Created by Michael Starke on 10.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDatabaseCreation.h"
#import "MPDocument.h"

@implementation MPDatabaseCreation

- (void)testCreateDatabaseVersion1 {
  MPDocument *document = [[MPDocument alloc] initWithVersion:MPDatabaseVersion3];
  STAssertNotNil(document, @"Document should be created");
  STAssertTrue(document.version == MPDatabaseVersion3, @"Database should be Version1");
  STAssertNotNil(document.treeV3, @"Database Tree needs to be Kdb3Tree");
  STAssertNil(document.treeV4,  @"Database Tree cannot be Kdb4Tree");
  STAssertTrue(document.decrypted, @"Document has to be decrypted new database is created");
  STAssertFalse(document.hasPasswordOrKey, @"Document has no Password/Keyfile and thus is not secured");
}

- (void)testCreateDatabaseVersion2 {
  MPDocument *document = [[MPDocument alloc] initWithVersion:MPDatabaseVersion4];
  STAssertNotNil(document, @"Document should be created");
  STAssertTrue(document.version == MPDatabaseVersion4, @"Database should be Version2");
  STAssertNotNil(document.treeV4, @"Database Tree needs to be Kdb4Tree");
  STAssertNil(document.treeV3, @"Database Tree cannot be Kdb3Tree");
  STAssertTrue(document.decrypted, @"Document has to be decrypted new database is created");
  STAssertFalse(document.hasPasswordOrKey, @"Document has no Password/Keyfile and thus is not secured");
}

@end
