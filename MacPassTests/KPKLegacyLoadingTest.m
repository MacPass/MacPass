//
//  KPKTreeLoadingTest.m
//  MacPass
//
//  Created by Michael Starke on 20.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKLegacyLoadingTest.h"
#import "KPKTree+Serializing.h"
#import "KPKPassword.h"
#import "KPKErrors.h"

@implementation KPKLegacyLoadingTest

- (void)setUp {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Test_Password_1234" withExtension:@"kdb"];
  _data = [NSData dataWithContentsOfURL:url];
  _password = [[KPKPassword alloc] initWithPassword:@"1234" key:nil];
}

- (void)tearDown {
  _data = nil;
  _password = nil;
}

- (void)testValidFile {
  KPKTree *tree = [[KPKTree alloc] initWithData:_data password:_password error:NULL];
  STAssertNotNil(tree, @"Loading should result in a tree object");
}

- (void)testInvalidFile {
  NSError *error;
  uint8 bytes[] = {0x00,0x11,0x22,0x33,0x44};
  NSData *data = [NSData dataWithBytes:bytes length:5];
  KPKTree *tree = [[KPKTree alloc] initWithData:data password:nil error:&error];
  STAssertNil(tree, @"Tree should be nil with invalid data");
  STAssertNotNil(error, @"Error object should have been created");
  STAssertTrue(KPKErrorUnknownFileFormat == [error code], @"Error should be Unknown file format");
}

@end
