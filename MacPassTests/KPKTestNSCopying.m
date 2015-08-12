//
//  KPKTestNSCopying.m
//  MacPass
//
//  Created by Michael Starke on 31.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KPKIconTypes.h"
#import "KPKGroup.h"
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
  ((KPKAttribute *)entry.customAttributes.lastObject).key = @"NewCustomKey";
  
  XCTAssertNotNil(copyEntry, @"Copied Entry cannot be nil");
  XCTAssertEqualObjects(copyEntry.title, @"Title", @"Titles should match");
  XCTAssertEqualObjects(copyEntry.url, @"URL", @"URLS should match");
  XCTAssertEqual(copyEntry.binaries.count, 1, @"Binareis should be copied");
  
  KPKBinary *copiedBinary = [copyEntry.binaries lastObject];
  XCTAssertTrue([copiedBinary.data isEqualToData:binary.data], @"Binary data should match");
  XCTAssertTrue([copiedBinary.name isEqualToString:binary.name], @"Binary names should macht");
}

- (void)testGroupCopying {
  
  /*
   root
    + Group A
      + Entry A
      + Group A1
      + Group A2
        + Entry B
   */
  
  KPKGroup *root = [[KPKGroup alloc] init];
  root.title = @"root";
  
  KPKGroup *groupA = [[KPKGroup alloc] init];
  groupA.title = @"Group A";
  groupA.isAutoTypeEnabled = KPKInheritNO;
  
  KPKGroup *groupA1 = [[KPKGroup alloc] init];
  groupA1.title = @"Group A1";
  groupA1.notes = @"Some notes";
  groupA1.iconId = KPKIconASCII;
  
  KPKGroup *groupA2 = [[KPKGroup alloc] init];
  groupA2.title = @"Group A2";
  groupA2.notes = @"More notes";
  groupA2.isSearchEnabled = KPKInheritYES;
  
  KPKEntry *entryA = [[KPKEntry alloc] init];
  entryA.title = @"Entry A";
  entryA.url = @"www.url.com";
  KPKEntry *entryB = [[KPKEntry alloc] init];
  entryB.title = @"Entry B";
  entryB.url = @"www.nope.com";

  
  [groupA addEntry:entryA];
  [groupA addGroup:groupA1];
  [groupA addGroup:groupA2];
  [groupA2 addEntry:entryB];
  
  [root addGroup:groupA];
  
  KPKGroup *copy = [root copy];
  
  XCTAssertEqualObjects(root, copy);
}

@end
