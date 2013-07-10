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
  STFail(@"Not implemented");
}

- (void)testCreateDatabaseVersion2 {
  MPDocument *document = [[MPDocument alloc] initWithVersion:MPDatabaseVersion4];
  STAssertNotNil(document, @"Document should be created");
  STAssertTrue(document.version == MPDatabaseVersion4, @"Database should be Version2");
  STAssertNotNil(document.treeV4, @"Database Tree needs to be Kdb4Tree");
  STFail(@"Not implemented");
}

@end
