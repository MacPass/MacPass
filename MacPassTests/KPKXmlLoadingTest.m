//
//  KPKXmlLoadingTest.m
//  MacPass
//
//  Created by Michael Starke on 23.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKXmlLoadingTest.h"
#import "KPKPassword.h"

#import "KPKTree+Serializing.h"
#import "KPKEntry.h"
#import "KPKGroup.h"

@implementation KPKXmlLoadingTest

- (void)setUp {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Test_Password_1234" withExtension:@"kdbx"];
  _data = [NSData dataWithContentsOfURL:url];
  _password = [[KPKPassword alloc] initWithPassword:@"1234" key:nil];
}

- (void)tearDown {
  _data = nil;
  _password = nil;
}

- (void)testLoading {
  NSError *error;
  KPKTree *tree = [[KPKTree alloc] initWithData:_data password:_password error:&error];
  STAssertNotNil(tree, @"Loading should result in a tree object");

  STAssertTrue([tree.root.groups count] == 0, @"Tree contains just root group");
  STAssertTrue([tree.root.entries count] == 1, @"Tree has only one entry");
}

@end
