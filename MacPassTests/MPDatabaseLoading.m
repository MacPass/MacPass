//
//  MPDatabaseLoadingTest.m
//  MacPass
//
//  Created by Michael Starke on 10.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDatabaseLoading.h"

#import "MPDocument.h"

#import "KPKTree.h"

@implementation MPDatabaseLoading


- (void)testLoadVersion1 {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Test_Password_1234" withExtension:@"kdb"];
  NSError *error = nil;
  MPDocument *document = [[MPDocument alloc] initWithContentsOfURL:url ofType:@"kdb" error:&error];
  STAssertNil(error, @"No Error should occur on loading");
  STAssertNotNil(document, @"Document cannot be nil");
  STAssertTrue(document.encrypted, @"Loaded but unencrypted should be not decrypted");
  STAssertTrue([document unlockWithPassword:@"1234" keyFileURL:nil error:&error], @"Should decrypt with password");
  STAssertNil(error, @"No Error should occur on unlocking with correct password");
  STAssertTrue((document.tree.minimumVersion = KPKLegacyVersion), @"Minimal Version should not increase with KDB File loaded");
  //STAssertTrue([document.fileType isEqualToString:[MPDocument fileTypeForVersion:KPKLegacyVersion]], @"File type needs to match opened file");
}

- (void)testVersion1WrongPassword {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Test_Password_1234" withExtension:@"kdb"];
  NSError *error = nil;
  MPDocument *document = [[MPDocument alloc] initWithContentsOfURL:url ofType:@"kdb" error:&error];
  STAssertNil(error, @"No Error should occur on loading");
  STAssertNotNil(document, @"Document should not be nil");
  STAssertTrue(document.encrypted, @"Loaded but unencrypted should be not decrypted");
  STAssertFalse([document unlockWithPassword:@"123" keyFileURL:nil error:&error], @"Decryption should fail");
  STAssertNotNil(error, @"Error should occur on unlocking with correct password");
}

- (void)testLoadDatabaseVerions2 {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Test_Password_1234" withExtension:@"kdbx"];
  NSError *error = nil;
  MPDocument *document = [[MPDocument alloc] initWithContentsOfURL:url ofType:@"kdbx" error:&error];
  STAssertNil(error, @"No Error should occur on loading");
  STAssertNotNil(document, @"Document cannot be nil");
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
