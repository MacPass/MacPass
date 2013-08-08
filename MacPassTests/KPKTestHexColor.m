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
  NSString *redHex = @"00ff0000";
  NSString *blueHex = @"000000ff";
  NSString *greeHex = @"0000ff00";
  
  NSColor *red = [NSColor colorWithHexString:redHex];
  NSColor *blue = [NSColor colorWithHexString:blueHex];
  NSColor *green = [NSColor colorWithHexString:greeHex];
  
  STAssertEquals([red redComponent], 1.0, @"Red color should have 100% red");
  STAssertEquals([red blueComponent], 0.0, @"Red color should have 0% blue");
  STAssertEquals([red greenComponent], 0.0, @"Red color should have 0% green");
  
  STAssertEquals([blue redComponent], 0.0, @"Blue color should have 0% red");
  STAssertEquals([blue blueComponent], 1.0, @"Blue color should have 100% blue");
  STAssertEquals([blue greenComponent], 0.0, @"Blue color should have 0% green");
  
  STAssertEquals([green redComponent], 0.0, @"Green color should have 0% red");
  STAssertEquals([green blueComponent], 0.0, @"Green color should have 0% blue");
  STAssertEquals([green greenComponent], 1.0, @"Green color should have 100% green");
}

- (void)testColorRefReading {
  uint32_t colorBytes = 0x000000FF;
  uint32_t swappedData = colorBytes;
  NSData *colorData = [NSData dataWithBytesNoCopy:&swappedData length:sizeof(uint32_t) freeWhenDone:NO];
  NSColor *color = [NSColor colorWithData:colorData];
  STAssertEquals([color redComponent], 0.0, @"Red 100%");
  STAssertEquals([color greenComponent], 0.0, @"Green 0%");
  STAssertEquals([color blueComponent], 1.0, @"Blue 100%");

}

@end
