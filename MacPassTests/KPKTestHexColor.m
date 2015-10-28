//
//  KPKTestHexColor.m
//  MacPass
//
//  Created by Michael Starke on 05.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KeePassKit.h"

@interface KPKTestHexColor : XCTestCase

@end

@implementation KPKTestHexColor

- (void)testHexToColor {
  NSString *redHex = @"FF000000";
  NSString *greeHex = @"00FF0000";
  NSString *blueHex = @"0000FF00";
  
  NSColor *red = [NSColor colorWithHexString:redHex];
  NSColor *green = [NSColor colorWithHexString:greeHex];
  NSColor *blue = [NSColor colorWithHexString:blueHex];
  
  XCTAssertEqual([red redComponent], 1.0, @"Red color should have 100%% red");
  XCTAssertEqual([red blueComponent], 0.0, @"Red color should have 0%% blue");
  XCTAssertEqual([red greenComponent], 0.0, @"Red color should have 0%% green");
  
  XCTAssertEqual([green redComponent], 0.0, @"Green color should have 0%% red");
  XCTAssertEqual([green greenComponent], 1.0, @"Green color should have 100%% green");
  XCTAssertEqual([green blueComponent], 0.0, @"Green color should have 0%% blue");
  
  XCTAssertEqual([blue redComponent], 0.0, @"Blue color should have 0%% red");
  XCTAssertEqual([blue greenComponent], 0.0, @"Blue color should have 0%% green");
  XCTAssertEqual([blue blueComponent], 1.0, @"Blue color should have 100%% blue");
}

- (void)testColorRefReading {
  uint32_t colorBytes = 0x000000FF;
  NSData *colorData = [NSData dataWithBytesNoCopy:&colorBytes length:3 freeWhenDone:NO];
  NSColor *color = [NSColor colorWithData:colorData];
  XCTAssertEqual([color redComponent], 1.0, @"Red 100%%");
  XCTAssertEqual([color greenComponent], 0.0, @"Green 0%%");
  XCTAssertEqual([color blueComponent], 0.0, @"Blue 100%%");
}

- (void)testColorRefWriting {
  uint32_t colorBytes = 0x000000FF;
  NSData *colorData = [NSData dataWithBytesNoCopy:&colorBytes length:4 freeWhenDone:NO];
  NSColor *color = [NSColor colorWithData:colorData];
  NSData *newData = [color colorData];
  XCTAssertEqualObjects(colorData, newData, @"Conversion should result in same data");
}

@end
