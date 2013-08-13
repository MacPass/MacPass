//
//  KPKTestKeyfileParsing.m
//  MacPass
//
//  Created by Michael Starke on 13.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKTestKeyfileParsing.h"
#import "NSData+Keyfile.h"

@implementation KPKTestKeyfileParsing

- (void)testXmlKeyfileLoadingValidFile {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Keepass2Key" withExtension:@"xml"];
  NSError *error;
  NSData *data = [NSData dataWithContentsOfKeyFile:url version:KPKXmlVersion error:&error];
  STAssertNotNil(data, @"Data should be loaded");
  STAssertNil(error, @"No error should occur on keyfile loading");
}

- (void)testXmlKeyfileLoadingCorruptData {
  STAssertFalse(NO, @"Not Implemented");
}

- (void)testXmlKeyfileLoadingMissingVersion {
  STAssertFalse(NO, @"Not Implemented");
}

- (void)testXmlKeyfileLoadingLowerVersion {
  STAssertFalse(NO, @"Not Implemented");
}

- (void)testXmlKeyfilGeneration {
  NSData *data = [NSData generateKeyfiledataForVersion:KPKXmlVersion];
  // Test if structure is sound;
  STAssertNotNil(data, @"Keydata should have been generated");
}

- (void)testLegacyKeyfileGeneration {
  NSData *data = [NSData generateKeyfiledataForVersion:KPKLegacyVersion];
  // test if strucutre is sound;
  STAssertNotNil(data, @"Keydata should have been generated");
}

@end
