//
//  MPTestModelChangeObservingHelper.m
//  MacPass
//
//  Created by Michael Starke on 29/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPModelChangeObserving.h"

@interface MPTestModelChangeObservingHelper : XCTestCase
@property (strong) MPModelChangeObservingHelper *helper;
@end

@implementation MPTestModelChangeObservingHelper

- (void)setUp {
  [super setUp];
  self.helper = [[MPModelChangeObservingHelper alloc] init];
}

- (void)tearDown {
  self.helper = nil;
  [super tearDown];
}

- (void)testAddObserver {
  [self.helper beginObservingModelChangesForKeyPath:@"testKey"];
  NSMutableSet *set = [self.helper valueForKey:@"observedPaths"];
  XCTAssertEqual(set.count, 1, @"Observed paths contains one element");
  XCTAssertTrue([set containsObject:@"testKey"], @"Observed set contains testKey");
}

- (void)testRemoveObserver {
  NSString *aKeyPath = @"testKeyPath";
  [self.helper beginObservingModelChangesForKeyPath:aKeyPath];
  [self.helper endObservingModelChangesForKeyPath:aKeyPath];
  NSMutableSet *set = [self.helper valueForKey:@"observedPaths"];
  XCTAssertFalse([set containsObject:aKeyPath], @"Observed path is removed after end of observation");
}

@end
