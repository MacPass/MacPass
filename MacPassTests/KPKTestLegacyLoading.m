//
//  KPKTreeLoadingTest.m
//  MacPass
//
//  Created by Michael Starke on 20.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//


#import <XCTest/XCTest.h>

#import "KPKTree+Serializing.h"
#import "KPKCompositeKey.h"
#import "KPKMetaData.h"
#import "KPKIcon.h"

#import "KPKErrors.h"

@interface KPKTestLegacyLoading : XCTestCase

@end

@implementation KPKTestLegacyLoading

- (void)testValidFile {
  KPKCompositeKey *password = [[KPKCompositeKey alloc] initWithPassword:@"1234" key:nil];
  NSData *data = [self _loadTestDataBase:@"Test_Password_1234" extension:@"kdb"];
  KPKTree *tree = [[KPKTree alloc] initWithData:data password:password error:NULL];
  XCTAssertNotNil(tree, @"Loading should result in a tree object");
}

- (void)testWrongPassword {
  KPKCompositeKey *password = [[KPKCompositeKey alloc] initWithPassword:@"wrongPassword" key:nil];
  NSData *data = [self _loadTestDataBase:@"KeePass1_native_test" extension:@"kdb"];
  NSError *error;
  KPKTree *tree = [[KPKTree alloc] initWithData:data password:password error:&error];
  XCTAssertNil(tree, @"Wrong password should yield nil tree");
  XCTAssertNotNil(error, @"Wrong password should yield error");
  //STAssertTrue([error code] == KPKErrorPasswordAndOrKeyfileWrong, @"Error code should be wrong password and/or keyfile");
}

- (void)testInvalidFile {
  NSError *error;
  uint8_t bytes[] = {0x00,0x11,0x22,0x33,0x44};
  NSData *data = [NSData dataWithBytes:bytes length:5];
  KPKTree *tree = [[KPKTree alloc] initWithData:data password:nil error:&error];
  XCTAssertNil(tree, @"Tree should be nil with invalid data");
  XCTAssertNotNil(error, @"Error object should have been created");
  XCTAssertTrue(KPKErrorUnknownFileFormat == [error code], @"Error should be Unknown file format");
}


- (void)testMetaParsing {
  NSData *data = [self _loadTestDataBase:@"KDB1_KeePassX_test" extension:@"kdb"];
  KPKCompositeKey *password = [[KPKCompositeKey alloc] initWithPassword:@"test" key:nil];
  KPKTree *tree = [[KPKTree alloc] initWithData:data password:password error:NULL];
  XCTAssertNotNil(tree, @"Tree shoudl be loaded" );
  
  KPKIcon *icon = [tree.metaData.customIcons lastObject];
  XCTAssertNotNil(icon, @"Should load one Icon");
}

- (NSData *)_loadTestDataBase:(NSString *)name extension:(NSString *)extension {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:name withExtension:extension];
  return [NSData dataWithContentsOfURL:url];
}

@end
