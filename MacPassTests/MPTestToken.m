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
  NSArray *tokens =[MPToken tokenizeString:@"{^}{USERNAME}^S+H{SPACE}"];
  XCTAssertEqual(7, tokens.count);
}


@end
