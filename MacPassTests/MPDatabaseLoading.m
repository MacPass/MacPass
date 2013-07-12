//
//  MPDatabaseLoadingTest.m
//  MacPass
//
//  Created by Michael Starke on 10.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDatabaseLoading.h"

#import "MPDocument.h"

@implementation MPDatabaseLoading


- (void)testLoadVersion1 {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Test_Password_1234" withExtension:@"kdb"];
  NSError *error = nil;
  MPDocument *document = [[MPDocument alloc] initWithContentsOfURL:url ofType:@"kdb" error:&error];
  STAssertNil(error, @"No Error should occur on loading");
  STAssertNotNil(document, @"Document cannot be nil");
  STAssertFalse(document.decrypted, @"Document is not decrypted after inital load");
  STAssertTrue([document unlockWithPassword:@"1234" keyFileURL:nil], @"Should decrypt with password");
  STAssertTrue(document.decrypted, @"Document is decrypted if decryptiong succeeds");
  STAssertNotNil(document.treeV3, @"Tree shoudl be version1");
  STAssertNil(document.treeV4, @"Tree should not be version2");
  STAssertTrue(document.version == MPDatabaseVersion3, @"Internal databse version should be correct");
}

- (void)testVersion1WrongPassword {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Test_Password_1234" withExtension:@"kdb"];
  NSError *error = nil;
  MPDocument *document = [[MPDocument alloc] initWithContentsOfURL:url ofType:@"kdb" error:&error];
  STAssertNil(error, @"No Error should occur on loading");
  STAssertNotNil(document, @"Document should not be nil");
  STAssertFalse(document.decrypted, @"Document is not decrypted after inital load");
  STAssertFalse([document unlockWithPassword:@"123" keyFileURL:nil], @"Decryption should fail");
  STAssertFalse(document.decrypted, @"Document is not decrypted with wrong password supplied");
}

- (void)testLoadDatabaseVerions2 {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Test_Password_1234" withExtension:@"kdbx"];
  NSError *error = nil;
  MPDocument *document = [[MPDocument alloc] initWithContentsOfURL:url ofType:@"kdbx" error:&error];
  STAssertNil(error, @"No Error should occur on loading");
  STAssertNotNil(document, @"Document cannot be nil");
  STAssertFalse(document.decrypted, @"Document is not decrypted after inital load");
  STAssertTrue([document unlockWithPassword:@"1234" keyFileURL:nil], @"Should decrypt with password");
  STAssertTrue(document.decrypted, @"Document is decrypted if decryptiong succeeds");
  STAssertNil(document.treeV3, @"Tree should not be version1");
  STAssertNotNil(document.treeV4, @"Tree shoud be version2");
  STAssertTrue(document.version == MPDatabaseVersion4, @"Internal database version should be correct");
}

@end
