//
//  KPKTextXMLUtilities.m
//  MacPass
//
//  Created by Michael Starke on 12/12/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "NSString+XMLUtilities.h"

@interface KPKTextXMLUtilities : XCTestCase

@end

@implementation KPKTextXMLUtilities

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testExample {
  NSString *unsave = @"*EORDIE\x10\x16\x12\x10";
  XCTAssertEqualObjects(@"*EORDIE", unsave.XMLCompatibleString);
}

@end
