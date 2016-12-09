//
//  MPDatabaseLoadingTest.m
//  MacPass
//
//  Created by Michael Starke on 10.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KeePassKit/KeePassKit.h>

#import "MPDocument.h"

@interface MPDatabaseLoading : XCTestCase

@end

@implementation MPDatabaseLoading


- (void)testLoadVersion1 {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Test_Password_1234" withExtension:@"kdb"];
  NSError *error = nil;
  MPDocument *document = [[MPDocument alloc] initWithContentsOfURL:url ofType:@"kdb" error:&error];
  XCTAssertNil(error, @"No Error should occur on loading");
  XCTAssertNotNil(document, @"Document cannot be nil");
  XCTAssertTrue(document.encrypted, @"Loaded but unencrypted should be not decrypted");
  XCTAssertTrue([document unlockWithPassword:@"1234" keyFileURL:nil error:&error], @"Should decrypt with password");
  XCTAssertNil(error, @"No Error should occur on unlocking with correct password");
  KPKFileVersion kdb = { KPKDatabaseFormatKdb, kKPKKdbFileVersion };
  XCTAssertEqual(NSOrderedSame, KPKFileVersionCompare(kdb, document.tree.minimumVersion), @"Minimal Version should not increase with KDB File loaded");
}

- (void)testVersion1WrongPassword {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Test_Password_1234" withExtension:@"kdb"];
  NSError *error = nil;
  MPDocument *document = [[MPDocument alloc] initWithContentsOfURL:url ofType:@"kdb" error:&error];
  XCTAssertNil(error, @"No Error should occur on loading");
  XCTAssertNotNil(document, @"Document should not be nil");
  XCTAssertTrue(document.encrypted, @"Loaded but unencrypted should be not decrypted");
  XCTAssertFalse([document unlockWithPassword:@"123" keyFileURL:nil error:&error], @"Decryption should fail");
  XCTAssertNotNil(error, @"Error should occur on unlocking with correct password");
}

- (void)testLoadDatabaseVerions2 {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Test_Password_1234" withExtension:@"kdbx"];
  NSError *error = nil;
  MPDocument *document = [[MPDocument alloc] initWithContentsOfURL:url ofType:@"kdbx" error:&error];
  XCTAssertNil(error, @"No Error should occur on loading");
  XCTAssertNotNil(document, @"Document cannot be nil");
  /*
  STAssertFalse(document.decrypted, @"Document is not decrypted after inital load");
  STAssertTrue([document unlockWithPassword:@"1234" keyFileURL:nil], @"Should decrypt with password");
  STAssertTrue(document.decrypted, @"Document is decrypted if decryptiong succeeds");
  STAssertNil(document.treeV3, @"Tree should not be version1");
  STAssertNotNil(document.treeV4, @"Tree shoud be version2");
  STAssertTrue(document.version == MPDatabaseVersion4, @"Internal database version should be correct");
   */
}

@end
