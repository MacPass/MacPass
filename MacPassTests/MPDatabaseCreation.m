//
//  MPDatabaseCreation.m
//  MacPass
//
//  Created by Michael Starke on 10.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MPDocument.h"
#import "KPKTree.h"
#import "KPKCompositeKey.h"

@interface MPDatabaseCreation : XCTestCase

@end

@implementation MPDatabaseCreation

- (void)testCreateNewDatabase {
  MPDocument *document = [[MPDocument alloc] init];
  XCTAssertNotNil(document, @"Document should be created");
  XCTAssertTrue(document.tree.minimumVersion == KPKLegacyVersion, @"Tree should be Legacy Version in defautl case");
  XCTAssertFalse(document.encrypted, @"Document cannot be encrypted at creation");
  XCTAssertFalse(document.compositeKey.hasPasswordOrKeyFile, @"Document has no Password/Keyfile and thus is not secured");
}

@end
