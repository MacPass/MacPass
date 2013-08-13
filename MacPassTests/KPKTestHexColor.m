//
//  KPKTestHexColor.m
//  MacPass
//
//  Created by Michael Starke on 05.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKTestHexColor.h"

#import "NSColor+KeePassKit.h"

@implementation KPKTestHexColor

- (void)testHexToColor {
  NSString *redHex = @"FF000000";
  NSString *greeHex = @"00FF0000";
  NSString *blueHex = @"0000FF00";
  
  NSColor *red = [NSColor colorWithHexString:redHex];
  NSColor *green = [NSColor colorWithHexString:greeHex];
  NSColor *blue = [NSColor colorWithHexString:blueHex];
  
  STAssertEquals([red redComponent], 1.0, @"Red color should have 100% red");
  STAssertEquals([red blueComponent], 0.0, @"Red color should have 0% blue");
  STAssertEquals([red greenComponent], 0.0, @"Red color should have 0% green");
  
  STAssertEquals([green redComponent], 0.0, @"Green color should have 0% red");
  STAssertEquals([green greenComponent], 1.0, @"Green color should have 100% green");
  STAssertEquals([green blueComponent], 0.0, @"Green color should have 0% blue");
  
  STAssertEquals([blue redComponent], 0.0, @"Blue color should have 0% red");
  STAssertEquals([blue greenComponent], 0.0, @"Blue color should have 0% green");
  STAssertEquals([blue blueComponent], 1.0, @"Blue color should have 100% blue");
}

- (void)testColorRefReading {
  uint32_t colorBytes = 0x000000FF;
  NSData *colorData = [NSData dataWithBytesNoCopy:&colorBytes length:3 freeWhenDone:NO];
  NSColor *color = [NSColor colorWithData:colorData];
  STAssertEquals([color redComponent], 1.0, @"Red 100%");
  STAssertEquals([color greenComponent], 0.0, @"Green 0%");
  STAssertEquals([color blueComponent], 0.0, @"Blue 100%");
}

- (void)testColorRefWriting {
  uint32_t colorBytes = 0x000000FF;
  NSData *colorData = [NSData dataWithBytesNoCopy:&colorBytes length:4 freeWhenDone:NO];
  NSColor *color = [NSColor colorWithData:colorData];
  NSData *newData = [color colorData];
  STAssertEqualObjects(colorData, newData, @"Convertion should result in same data");
}

@end
