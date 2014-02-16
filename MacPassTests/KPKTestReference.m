//
//  KPKTestReference.m
//  MacPass
//
//  Created by Michael Starke on 15.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Commands.h"

@interface KPKTestReference : XCTestCase

@end

@implementation KPKTestReference

- (void)testCorrectReference {
  NSString *reference = @"This is some nice stuff {REF:T@U:blubber} and another Reference {REF:U@I:2687345AASTA}";
  [reference resolveReferencesWithTree:nil];
}

- (void)testWrongRefernceFormat {
  XCTFail(@"Missing Test");
}

- (void)testUnknownReference {
  XCTFail(@"Missing Test");
}

- (void)testMultipleMatchinRefernce {
  XCTFail(@"Missing Test");
}

@end
