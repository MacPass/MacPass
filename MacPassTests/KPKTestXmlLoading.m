//
//  KPKXmlLoadingTest.m
//  MacPass
//
//  Created by Michael Starke on 23.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KeePassKit.h"


@interface KPKTestXmlLoading : XCTestCase {
@private
  NSData *_data;
  KPKCompositeKey *_password;
}

@end


@implementation KPKTestXmlLoading

- (void)setUp {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Test_Password_1234" withExtension:@"kdbx"];
  _data = [NSData dataWithContentsOfURL:url];
  _password = [[KPKCompositeKey alloc] initWithPassword:@"1234" key:nil];
}

- (void)tearDown {
  _data = nil;
  _password = nil;
}

- (void)testLoading {
  NSError *error;
  KPKTree *tree = [[KPKTree alloc] initWithData:_data password:_password error:&error];
  XCTAssertNotNil(tree, @"Loading should result in a tree object");

  XCTAssertEqual(tree.root.groups.count, 0, @"Tree contains just root group");
  XCTAssertEqual(tree.root.entries.count, 1, @"Tree has only one entry");
}

- (void)testAutotypeLoading {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Autotype_test" withExtension:@"kdbx"];
  KPKCompositeKey *password = [[KPKCompositeKey alloc] initWithPassword:@"test" key:nil];
  NSError *error;
  KPKTree *tree = [[KPKTree alloc] initWithContentsOfUrl:url password:password error:&error];
  XCTAssertNotNil(tree, @"Tree shoud be loaded");
  KPKEntry *entry = tree.root.entries[0];
  XCTAssertNotNil(entry, @"Entry should be there");
  XCTFail(@"Uncomplete Test!");
}

@end
