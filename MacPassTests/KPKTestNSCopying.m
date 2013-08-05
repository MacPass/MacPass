//
//  KPKTestNSCopying.m
//  MacPass
//
//  Created by Michael Starke on 31.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKTestNSCopying.h"
#import "KPKEntry.h"
#import "KPKAttribute.h"
#import "KPKBinary.h"


@implementation KPKTestNSCopying

- (void)testAttributeCopying {
  KPKAttribute *attribute = [[KPKAttribute alloc] initWithKey:@"Key" value:@"Value" isProtected:NO];
  KPKAttribute *copy = [attribute copy];
  
  attribute.key = @"NewKey";
  attribute.value = @"NewValue";
  attribute.isProtected = YES;
  
  STAssertNotNil(copy, @"Copy shoule exist");
  STAssertTrue([copy.key isEqualToString:@"Key"], @"Copy key should be key");
  STAssertTrue([copy.value isEqualToString:@"Value"], @"Copy value should be value");
  STAssertFalse(copy.isProtected, @"Copy should not be protected");
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
  [entry addCustomAttribute:[[KPKAttribute alloc] initWithKey:@"Custom" value:@"Value" isProtected:NO]];

  KPKEntry *copyEntry = [entry copy];
  
  entry.title = @"NewTitle";
  [entry removeBinary:binary];
  [[entry.customAttributes lastObject] setKey:@"NewCustomKey"];
  
  STAssertNotNil(copyEntry, @"Copied Entry cannot be nil");
  STAssertTrue([copyEntry.title isEqualToString:@"Title"], @"Titles should match");
  STAssertTrue([copyEntry.url isEqualToString:@"URL"], @"URLS should match");
  STAssertTrue([copyEntry.binaries count] == 1, @"Binareis should be copied");
  
  KPKBinary *copiedBinary = [copyEntry.binaries lastObject];
  STAssertTrue([copiedBinary.data isEqualToData:binary.data], @"Binary data should match");
  STAssertTrue([copiedBinary.name isEqualToString:binary.name], @"Binary names should macht");
}

@end
