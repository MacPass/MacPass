//
//  KPKLegacyWritingTest.m
//  MacPass
//
//  Created by Michael Starke on 02.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KPKCompositeKey.h"
#import "KPKTree+Serializing.h"

@interface KPKTestLegacyWriting : XCTestCase

@end

@implementation KPKTestLegacyWriting

- (void)testWriting {
  NSError __autoreleasing *error = nil;
  NSURL *dbUrl = [self _urlForFile:@"CustomIcon_Password_1234" extension:@"kdbx"];
  KPKCompositeKey *password = [[KPKCompositeKey alloc] initWithPassword:@"1234" key:nil];
  KPKTree *tree = [[KPKTree alloc] initWithContentsOfUrl:dbUrl password:password error:&error];
  XCTAssertNotNil(tree, @"Tree should be created");
  error = nil;
  NSData *data = [tree encryptWithPassword:password forVersion:KPKLegacyVersion error:&error];
  XCTAssertNotNil(data, @"Serialized Data shoudl be created");
  NSString *tempFile = [NSTemporaryDirectory() stringByAppendingString:@"CustomIcon_Password_1234.kdb"];
  NSLog(@"Saved to %@", tempFile);
  [data writeToFile:tempFile atomically:YES];
  KPKTree *loadTree = [[KPKTree alloc] initWithData:data password:password error:&error];
  XCTAssertNotNil(loadTree, @"Tree should be loadable from kdb file data");
}

- (NSData *)_dataForFile:(NSString *)name extension:(NSString *)extension {
  NSURL *url = [self _urlForFile:name extension:extension];
  return [NSData dataWithContentsOfURL:url];
}

- (NSURL *)_urlForFile:(NSString *)file extension:(NSString *)extension {
  return [[NSBundle bundleForClass:[self class]] URLForResource:file withExtension:extension];
}


@end
