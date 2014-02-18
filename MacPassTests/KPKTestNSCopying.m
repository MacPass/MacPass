//
//  KPKTestNSCopying.m
//  MacPass
//
//  Created by Michael Starke on 31.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KPKEntry.h"
#import "KPKAttribute.h"
#import "KPKBinary.h"
#import "KPKXmlElements.h"

@interface KPKTestNSCopying : XCTestCase

@end

@implementation KPKTestNSCopying

- (void)testAttributeCopying {
  KPKAttribute *attribute = [[KPKAttribute alloc] initWithKey:@"Key" value:kKPKXmlValue isProtected:NO];
  KPKAttribute *copy = [attribute copy];
  
  attribute.key = @"NewKey";
  attribute.value = @"NewValue";
  attribute.isProtected = YES;
  
  XCTAssertNotNil(copy, @"Copy shoule exist");
  XCTAssertTrue([copy.key isEqualToString:@"Key"], @"Copy key should be key");
  XCTAssertTrue([copy.value isEqualToString:kKPKXmlValue], @"Copy value should be value");
  XCTAssertFalse(copy.isProtected, @"Copy should not be protected");
}

- (void)testEntryCopying {
  KPKEntry *entry = [[KPKEntry alloc] init];
  
  entry.title = @"Title";
  entry.url = @"URL";
  entry.username = @"Username";
  entry.password = @"Password";
  
  uint8_t bytes[] = { 0xFF, 0x00, 0xFF, 0x00, 0xFF };
  NSData *data = [[NSData alloc] initWithBytes:bytes length:5];
  
  KPKBinary *binary = [[KPKBinary alloc] init];
  binary.data = data;
  binary.name = @"Binary";
  
  [entry addBinary:binary];
  [entry addCustomAttribute:[[KPKAttribute alloc] initWithKey:@"Custom" value:kKPKXmlValue isProtected:NO]];

  KPKEntry *copyEntry = [entry copy];
  
  entry.title = @"NewTitle";
  [entry removeBinary:binary];
  [[entry.customAttributes lastObject] setKey:@"NewCustomKey"];
  
  XCTAssertNotNil(copyEntry, @"Copied Entry cannot be nil");
  XCTAssertTrue([copyEntry.title isEqualToString:@"Title"], @"Titles should match");
  XCTAssertTrue([copyEntry.url isEqualToString:@"URL"], @"URLS should match");
  XCTAssertTrue([copyEntry.binaries count] == 1, @"Binareis should be copied");
  
  KPKBinary *copiedBinary = [copyEntry.binaries lastObject];
  XCTAssertTrue([copiedBinary.data isEqualToData:binary.data], @"Binary data should match");
  XCTAssertTrue([copiedBinary.name isEqualToString:binary.name], @"Binary names should macht");
}

@end
