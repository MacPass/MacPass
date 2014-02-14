//
//  KPKTestNSCopying.m
//  MacPass
//
//  Created by Michael Starke on 31.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKTestNSCoding.h"
#import "KPKEntry.h"
#import "KPKBinary.h"
#import "KPKAttribute.h"
#import "KPKXmlElements.h"

@implementation KPKTestNSCoding

- (void)testAttributeCoding {
  KPKAttribute *attribute = [[KPKAttribute alloc] initWithKey:kKPKXmlKey value:@"Value" isProtected:YES];
  NSData *data =  [self encode:attribute];
  KPKAttribute *copy = [self decode:data ofClass:[KPKAttribute class]];
  
  STAssertTrue([copy.value isEqualToString:attribute.value], @"Values should be preseved");
  STAssertTrue([copy.key isEqualToString:attribute.key], @"Keys should be preserved");
  STAssertTrue(copy.isProtected == attribute.isProtected, @"Protected status should be the same");
}

- (void)testBinaryCoding {

}

- (void)testEntryCoding {
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

  NSData *encodedData = [self encode:entry];
  KPKEntry *copyEntry = [self decode:encodedData ofClass:[KPKEntry class]];
  
  STAssertNotNil(copyEntry, @"Copied Entry cannot be nil");
  STAssertTrue([copyEntry.title isEqualToString:entry.title], @"Titles should match");
  STAssertTrue([copyEntry.url isEqualToString:entry.url], @"URLS should match");
  STAssertTrue([copyEntry.binaries count] == 1, @"Binareis should be copied");

  KPKBinary *copiedBinary = [copyEntry.binaries lastObject];
  STAssertTrue([copiedBinary.data isEqualToData:binary.data], @"Binary data should match");
  STAssertTrue([copiedBinary.name isEqualToString:binary.name], @"Binary names should macht");
}


- (void)testGroupCoding {
  
}


- (NSData *)encode:(id)object {
  NSMutableData *data = [[NSMutableData alloc] initWithCapacity:500];
  NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  [object encodeWithCoder:archiver];
  [archiver finishEncoding];
  return data;
}

- (id)decode:(NSData *)data ofClass:(Class)class {
  NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
  id object = [[class alloc] initWithCoder:unarchiver];
  [unarchiver finishDecoding];
  return object;
}

@end
