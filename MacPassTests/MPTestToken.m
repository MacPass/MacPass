//
//  MPTestToken.m
//  MacPassTests
//
//  Created by Michael Starke on 07.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPToken.h"

@interface MPTestToken : XCTestCase

@end

@implementation MPTestToken

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testTokenizing {
  NSArray <MPToken *> *tokens = [MPToken tokenizeString:@"{^}{USERNAME}^S+H{SPACE}"];
  XCTAssertEqual(7, tokens.count);
  
  XCTAssertEqual(7, tokens.count);
  XCTAssertEqualObjects(@"{^}", tokens[0].value);
  XCTAssertEqualObjects(@"{USERNAME}", tokens[1].value);
  XCTAssertEqualObjects(@"^", tokens[2].value);
  XCTAssertEqualObjects(@"S", tokens[3].value);
  XCTAssertEqualObjects(@"+", tokens[4].value);
  XCTAssertEqualObjects(@"H", tokens[5].value);
  XCTAssertEqualObjects(@"{SPACE}", tokens[6].value);
  
  tokens = [MPToken tokenizeString:@"{^}{USERNAME 2}^S+H{SPACE 2}"];
  XCTAssertEqual(7, tokens.count);
  XCTAssertEqualObjects(@"{^}", tokens[0].value);
  XCTAssertEqualObjects(@"{USERNAME 2}", tokens[1].value);
  XCTAssertEqualObjects(@"^", tokens[2].value);
  XCTAssertEqualObjects(@"S", tokens[3].value);
  XCTAssertEqualObjects(@"+", tokens[4].value);
  XCTAssertEqualObjects(@"H", tokens[5].value);
  XCTAssertEqualObjects(@"{SPACE 2}", tokens[6].value);
}


@end
