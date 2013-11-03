//
//  MPDatabaseCreation.m
//  MacPass
//
//  Created by Michael Starke on 10.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDatabaseCreation.h"
#import "MPDocument.h"
#import "KPKTree.h"
#import "KPKCompositeKey.h"

@implementation MPDatabaseCreation

- (void)testCreateNewDatabase {
  MPDocument *document = [[MPDocument alloc] init];
  STAssertNotNil(document, @"Document should be created");
  STAssertTrue(document.tree.minimumVersion == KPKLegacyVersion, @"Tree should be Legacy Version in defautl case");
  STAssertFalse(document.encrypted, @"Document cannot be encrypted at creation");
  STAssertFalse(document.compositeKey.hasPasswordOrKeyFile, @"Document has no Password/Keyfile and thus is not secured");
}

@end
