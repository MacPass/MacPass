//
//  KPKTreeLoadingTest.m
//  MacPass
//
//  Created by Michael Starke on 20.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKTreeLoadingTest.h"
#import "KPKTreeLoader.h"

@implementation KPKTreeLoadingTest

- (void)setUp {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Test_Password_1234" withExtension:@"kdbx"];
  _data = [NSData dataWithContentsOfURL:url];
}

- (void)tearDown {
  _data = nil;
}

- (void)testLoading {
  KPKTreeLoader *loader = [[KPKTreeLoader alloc] initWithData:_data];
  KPKTree *tree = [loader loadTree];
  STAssertNil(tree, @"Loading should broken");
}

@end
