//
//  KPKTestNSCopying.m
//  MacPass
//
//  Created by Michael Starke on 31.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "KPKEntry.h"
#import "KPKGroup.h"
#import "KPKBinary.h"
#import "KPKAttribute.h"
#import "KPKXmlElements.h"
#import "KPKIcon.h"

#import "NSData+Random.h"

@interface KPKTestNSCoding : XCTestCase

@end

@implementation KPKTestNSCoding

- (void)testAttributeCoding {
  KPKAttribute *attribute = [[KPKAttribute alloc] initWithKey:kKPKXmlKey value:kKPKXmlValue isProtected:YES];
  NSData *data =  [self encode:attribute];
  KPKAttribute *copy = [self decode:data ofClass:[KPKAttribute class]];
  
  XCTAssertTrue([copy.value isEqualToString:attribute.value], @"Values should be preseved");
  XCTAssertTrue([copy.key isEqualToString:attribute.key], @"Keys should be preserved");
  XCTAssertTrue(copy.isProtected == attribute.isProtected, @"Protected status should be the same");
}

- (void)testBinaryCoding {
  KPKBinary *binary = [[KPKBinary alloc] init];
  binary.name = @"Binary";
  binary.data = [NSData dataWithRandomBytes:1*1024*1024];
  
  NSData *data = [self encode:binary];
  KPKBinary *decodedBinary = [self decode:data ofClass:[KPKBinary class]];
  
  
  XCTAssertTrue([decodedBinary.data isEqualToData:binary.data]);
  XCTAssertTrue([decodedBinary.name isEqualToString:binary.name]);
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
  [entry addCustomAttribute:[[KPKAttribute alloc] initWithKey:@"Custom" value:kKPKXmlValue isProtected:NO]];
  
  NSData *encodedData = [self encode:entry];
  KPKEntry *copyEntry = [self decode:encodedData ofClass:[KPKEntry class]];
  
  XCTAssertNotNil(copyEntry, @"Copied Entry cannot be nil");
  XCTAssertTrue([copyEntry.title isEqualToString:entry.title], @"Titles should match");
  XCTAssertTrue([copyEntry.url isEqualToString:entry.url], @"URLS should match");
  XCTAssertTrue([copyEntry.binaries count] == 1, @"Binaries should be copied");
  
  KPKBinary *copiedBinary = [copyEntry.binaries lastObject];
  XCTAssertTrue([copiedBinary.data isEqualToData:binary.data], @"Binary data should match");
  XCTAssertTrue([copiedBinary.name isEqualToString:binary.name], @"Binary names should match");
}

- (void)testIconCoding {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *imageURL = [myBundle URLForImageResource:@"image.png"];
  KPKIcon *icon = [[KPKIcon alloc] initWithImageAtURL:imageURL];
  NSData *data = [self encode:icon];
  KPKIcon *decodedIcon = [self decode:data ofClass:[KPKIcon class]];
  NSBitmapImageRep *originalRep = [[icon.image representations] lastObject];
  NSBitmapImageRep *decodedRep = [[decodedIcon.image representations] lastObject];
  XCTAssertTrue([originalRep isKindOfClass:[NSBitmapImageRep class]]);
  XCTAssertTrue([decodedRep isKindOfClass:[NSBitmapImageRep class]]);
  /*
   We cannot assert bit depth since TIFF conversion might just strip a full white alpha channel
   XCTAssertEqual([originalRep bitsPerPixel], [decodedRep bitsPerPixel]);
   */
  XCTAssertEqual([originalRep pixelsHigh], [decodedRep pixelsHigh]);
  XCTAssertEqual([originalRep pixelsWide], [decodedRep pixelsWide]);
  
  NSData *originalData = [icon.image TIFFRepresentation];
  NSData *decodedData = [decodedIcon.image TIFFRepresentation];
  XCTAssertTrue([originalData isEqualToData:decodedData]);
}

- (void)testGroupCoding {
  KPKGroup *group = [[KPKGroup alloc] init];
  group.name = @"A Group";
  group.iconId = 50;
  group.notes = @"Some notes";
  KPKEntry *entry = [[KPKEntry alloc] init];
  entry.title = @"Entry";
  entry.url = @"www.url.com";
  [group addEntry:entry];
  
  NSData *data = [self encode:group];
  KPKGroup *decodedGroup = [self decode:data ofClass:[KPKGroup class]];
  
  XCTAssertTrue([group.uuid isEqual:decodedGroup.uuid]);
  XCTAssertTrue([group.name isEqualToString:decodedGroup.name]);
  XCTAssertEqual([group.entries count], [decodedGroup.entries count]);
  XCTAssertEqual(group.iconId, decodedGroup.iconId);
  XCTAssertTrue([group.notes isEqualToString:decodedGroup.notes]);

  KPKEntry *decodedEntry = [decodedGroup entryForUUID:entry.uuid];
  XCTAssertNotNil(decodedEntry);
  XCTAssertEqualObjects(decodedEntry.parent, decodedGroup);
  XCTAssertTrue([decodedEntry isEqualToEntry:entry]);
}

- (NSData *)encode:(id)object {
  NSMutableData *data = [[NSMutableData alloc] initWithCapacity:500];
  NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  [object encodeWithCoder:archiver];
  [archiver finishEncoding];
  return data;
}

- (id)decode:(NSData *)data ofClass:(Class)class usingSecureCoding:(BOOL)secureCoding {
  NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
  id object = [[class alloc] initWithCoder:unarchiver];
  [unarchiver finishDecoding];
  return object;
}


- (id)decode:(NSData *)data ofClass:(Class)class {
  return [self decode:data ofClass:class usingSecureCoding:NO];
}

@end
