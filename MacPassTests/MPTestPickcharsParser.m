//
//  MPTestPickcharsParser.m
//  MacPassTests
//
//  Created by Michael Starke on 29.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPPickcharsParser.h"

@interface MPTestPickcharsParser : XCTestCase

@end

@implementation MPTestPickcharsParser

- (void)testValidOptionsParser {
  MPPickcharsParser *parser = [[MPPickcharsParser alloc] initWithOptions:@"Count=10,Hide=false,Conv=D,Conv-Offset=11,Conv-Fmt=0?aA"];
  XCTAssertEqual(10, parser.pickCount);
  XCTAssertEqual(NO, parser.hideCharacters);
  XCTAssertEqual(YES, parser.convertToDownArrows);
  XCTAssertEqual(11, parser.checkboxOffset);
  XCTAssertEqualObjects(@"0?aA", parser.checkboxFormat);
}


- (void)testInvalidOptionsParser {
  MPPickcharsParser *parser = [[MPPickcharsParser alloc] initWithOptions:@"Count=-10,Hide=whatever,Con=D,Conv-Offset=20,Conv-Fmt=0A"];
  XCTAssertEqual(0, parser.pickCount); // negative count will result in 0-count
  XCTAssertEqual(YES, parser.hideCharacters); // option invalid, default is YES
  XCTAssertEqual(NO, parser.convertToDownArrows); // option was invalid, default is NO
  XCTAssertEqual(20, parser.checkboxOffset);
  XCTAssertEqualObjects(@"0A", parser.checkboxFormat);
}

@end
