//
//  KPKTestPerformance.m
//  MacPass
//
//  Created by Michael Starke on 21/10/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KeePassKit.h"

NSUInteger const _kKPKEntryCount = 1000;

@interface KPKTestPerformance : XCTestCase {
  KPKEntry *testEntry;
}
@end

@implementation KPKTestPerformance

- (void)setUp {
  [super setUp];
  testEntry = [[KPKEntry alloc] init];
  NSUInteger count = _kKPKEntryCount;
  while(count-- > 0) {
    [testEntry addCustomAttribute:[[KPKAttribute alloc] initWithKey:@(count).stringValue
                                                              value:@(count).stringValue]];
  }
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testAttributeLookupPerformanceA {
  [self measureBlock:^{
    [testEntry customAttributeForKey:@(0).stringValue];
  }];
}

- (void)testAttributeLookupPerformanceB {
  [self measureBlock:^{
    [testEntry customAttributeForKey:@(_kKPKEntryCount - 1).stringValue];
  }];
}

- (void)testAttributeLookupPerformanceC {
  [self measureBlock:^{
    [testEntry customAttributeForKey:kKPKTitleKey];
  }];
}


@end
