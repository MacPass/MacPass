//
//  MPTestPickcharsParser.m
//  MacPassTests
//
//  Created by Michael Starke on 29.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MPPickcharsParser.h"
#import "MPPickcharsParser_Private.h"

@interface MPTestPickcharsParser : XCTestCase

@end

@implementation MPTestPickcharsParser

- (void)testValidOptionsParser {
  MPPickcharsParser *parser = [[MPPickcharsParser alloc] initWithOptions:@"Count=10,Hide=false,Conv=D,Conv-Offset=11,Conv-Fmt=0?aA"];
  XCTAssertEqual(10, parser.pickCount);
  XCTAssertEqual(NO, parser.hideCharacters);
  XCTAssertEqual(YES, parser.convertToDownArrows);
  XCTAssertEqual(11, parser.checkboxOffset);
  
  NSString *result = [parser processPickedString:@"1B0f"];
  
}


- (void)testInvalidOptionsParser {
  MPPickcharsParser *parser = [[MPPickcharsParser alloc] initWithOptions:@"Count=-10,Hide=whatever,Con=D,Conv-Offset=20,Conv-Fmt=1A"];
  XCTAssertEqual(0, parser.pickCount); // negative count will result in 0-count
  XCTAssertEqual(YES, parser.hideCharacters); // option invalid, default is YES
  XCTAssertEqual(NO, parser.convertToDownArrows); // option was invalid, default is NO
  XCTAssertEqual(20, parser.checkboxOffset);
}

- (void)testConvertToDownArrows {
  MPPickcharsParser *parser = [[MPPickcharsParser alloc] init];
  parser.convertToDownArrows = YES;
  NSString *result = [parser processPickedString:@"105"];  // 1 + 0 + 5 = 6
  XCTAssertEqualObjects(result, @"{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}");
  result = [parser processPickedString:@"ccb"]; // 2 + 2 + 1 = 5
  XCTAssertEqualObjects(result, @"{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}");
  result = [parser processPickedString:@"CCB"]; // 2 + 2 + 1 = 5
  XCTAssertEqualObjects(result, @"{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}");
  parser.checkboxOffset = 2;
  result = [parser processPickedString:@"105"]; // 1 + 0 + 5 + (3 * 2) = 6 + 6 = 12
  XCTAssertEqualObjects(result, @"{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}");
  result = [parser processPickedString:@"ccb"]; // 2 + 2 + 1 + (2 * 2) = 5 + 6 = 12
  XCTAssertEqualObjects(result, @"{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}");
}



@end
