//
//  KPKTestAutotypeNormalization.m
//  MacPass
//
//  Created by Michael Starke on 18.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Commands.h"

@interface KPKTestAutotypeNormalization : XCTestCase

@end

@implementation KPKTestAutotypeNormalization

- (void)testNormalization {
  NSString *normalized = [@"Whoo %{%}{^}{SHIFT}+ {SPACE}{ENTER}^V%V~T" normalizedCommand];
  XCTAssertTrue([normalized isEqualToString:@"Whoo{SPACE}{ALT}{%}{^}{SHIFT}{SHIFT}{SPACE}{SPACE}{ENTER}{CONTROL}V{ALT}V{ENTER}T"], @"Normalization shoudl resutl in supplied string");
}

@end
