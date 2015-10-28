//
//  KPKTestUUIDAdditions.m
//  MacPass
//
//  Created by Michael Starke on 16.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KeePassKit.h"

@interface KPKTestUUIDAdditions : XCTestCase

@end

@implementation KPKTestUUIDAdditions

- (void)testUndelemitedUUID {
  NSUUID *uuid1 = [[NSUUID alloc] initWithUUIDString:@"31C1F2E6-BF71-4350-BE58-05216AFC5AFF"];
  NSUUID *uuid2 = [[NSUUID alloc] initWithUndelemittedUUIDString:@"31C1F2E6BF714350BE5805216AFC5AFF"];
  XCTAssertTrue([uuid1 isEqual:uuid2], @"UUIDs should match");
}

@end
