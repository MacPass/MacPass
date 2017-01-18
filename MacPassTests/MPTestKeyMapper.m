//
//  MPTestKeyMapper.m
//  MacPass
//
//  Created by Michael Starke on 18/01/2017.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Carbon/Carbon.h>

#import "MPKeyMapper.h"


@interface MPTestKeyMapper : XCTestCase

@end

@implementation MPTestKeyMapper

- (void)testKeyMapper {
  CGEventFlags flags = 0;
  CGKeyCode keyCode = [MPKeyMapper keyCodeForCharacter:@"A" modifier:&flags];
  XCTAssertEqual(kVK_ANSI_A, keyCode);
  XCTAssertEqual(kCGEventFlagMaskShift, flags);
  
  /* Test only works for german keyboard layout!
  XCTAssertEqualObjects(@"a",[MPKeyMapper stringForKey:kVK_ANSI_A modifier:0]);
  XCTAssertEqualObjects(@"A",[MPKeyMapper stringForKey:kVK_ANSI_A modifier:kCGEventFlagMaskShift]);
  
  XCTAssertEqualObjects(@"8",[MPKeyMapper stringForKey:kVK_ANSI_8 modifier:0]);
  XCTAssertEqualObjects(@"(",[MPKeyMapper stringForKey:kVK_ANSI_8 modifier:kCGEventFlagMaskShift]);
  XCTAssertEqualObjects(@"{",[MPKeyMapper stringForKey:kVK_ANSI_8 modifier:kCGEventFlagMaskAlternate]);

  XCTAssertEqualObjects(@"n",[MPKeyMapper stringForKey:kVK_ANSI_N modifier:0]);
  XCTAssertEqualObjects(@"N",[MPKeyMapper stringForKey:kVK_ANSI_N modifier:kCGEventFlagMaskShift]);
  XCTAssertEqualObjects(@"~",[MPKeyMapper stringForKey:kVK_ANSI_N modifier:kCGEventFlagMaskAlternate]);
  */
}

@end
