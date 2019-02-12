//
//  MPTestIndexPathAdditions.m
//  MacPassTests
//
//  Created by Michael Starke on 07.11.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSIndexPath+MPAdditions.h"

@interface MPTestIndexPathAdditions : XCTestCase

@end

@implementation MPTestIndexPathAdditions

- (void)testContainsA {
  NSUInteger indexes1[] = {0,1,2,3};
  NSUInteger indexes2[] = {0,1,3};
  
  NSIndexPath *path1 = [[NSIndexPath alloc] initWithIndexes:indexes1 length:sizeof(indexes1)/sizeof(NSUInteger)];
  NSIndexPath *path2 = [[NSIndexPath alloc] initWithIndexes:indexes2 length:sizeof(indexes2)/sizeof(NSUInteger)];

  XCTAssertFalse([path1 containsIndexPath:path2]);
  XCTAssertFalse([path2 containsIndexPath:path1]);
}

- (void)testContainsB {
  NSUInteger indexes1[] = {0,2,3};
  NSUInteger indexes2[] = {0,2};
  
  NSIndexPath *path1 = [[NSIndexPath alloc] initWithIndexes:indexes1 length:sizeof(indexes1)/sizeof(NSUInteger)];
  NSIndexPath *path2 = [[NSIndexPath alloc] initWithIndexes:indexes2 length:sizeof(indexes2)/sizeof(NSUInteger)];
  
  XCTAssertFalse([path1 containsIndexPath:path2]);
  XCTAssertTrue([path2 containsIndexPath:path1]);
}

- (void)testContainsC {
  NSUInteger indexes1[] = {10,1,3};
  NSUInteger indexes2[] = {10,1,3};
  
  NSIndexPath *path1 = [[NSIndexPath alloc] initWithIndexes:indexes1 length:sizeof(indexes1)/sizeof(NSUInteger)];
  NSIndexPath *path2 = [[NSIndexPath alloc] initWithIndexes:indexes2 length:sizeof(indexes2)/sizeof(NSUInteger)];
  
  XCTAssertTrue([path1 containsIndexPath:path2]);
  XCTAssertTrue([path2 containsIndexPath:path1]);
}



@end
