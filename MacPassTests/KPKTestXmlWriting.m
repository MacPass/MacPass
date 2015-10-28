//
//  KPKTestXmlWriting.m
//  MacPass
//
//  Created by Michael Starke on 20.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KeePassKit.h"


@interface KPKTestXmlWriting : XCTestCase

@end


@implementation KPKTestXmlWriting

- (void)testXmlWriting {
  NSData *data = [self _loadTestDataBase:@"CustomIcon_Password_1234" extension:@"kdbx"];
  NSError *error;
  KPKCompositeKey *password = [[KPKCompositeKey alloc] initWithPassword:@"1234" key:nil];
  KPKTree *tree = [[KPKTree alloc] initWithData:data password:password error:&error];
  error = nil;
  NSData *saveData = [tree encryptWithPassword:password forVersion:KPKXmlVersion error:&error];
  XCTAssertNotNil(saveData, @"Serialization should yield data");
  NSString *tempFile = [NSTemporaryDirectory() stringByAppendingString:@"CustomIcon_Password_1234_save.kdbx"];
  NSLog(@"Saved file to %@", tempFile);
  [saveData writeToFile:tempFile atomically:YES];
  
  error = nil;
  NSURL *url = [NSURL fileURLWithPath:tempFile];
  KPKTree *reloadedTree = [[KPKTree alloc] initWithContentsOfUrl:url password:password error:&error];
  XCTAssertNotNil(reloadedTree, @"Reloaded tree should not be nil");
}

- (NSData *)_loadTestDataBase:(NSString *)name extension:(NSString *)extension {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:name withExtension:extension];
  return [NSData dataWithContentsOfURL:url];
}

@end
