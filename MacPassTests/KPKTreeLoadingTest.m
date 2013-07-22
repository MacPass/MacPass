//
//  KPKTreeLoadingTest.m
//  MacPass
//
//  Created by Michael Starke on 20.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKTreeLoadingTest.h"
#import "KPKTreeCryptor.h"
#import "KPKPassword.h"

@implementation KPKTreeLoadingTest

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
  KPKTreeCryptor *cryptor = [KPKTreeCryptor treeCryptorWithData:_data password:_password];
  KPKTree *tree = [cryptor decryptTree:NULL];
  STAssertNotNil(tree, @"Loading should result in a tree object");
}

@end
