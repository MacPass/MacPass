//
//  KPKTestReference.m
//  MacPass
//
//  Created by Michael Starke on 15.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KPKAttribute.h"
#import "KPKEntry.h"
#import "KPKGroup.h"
#import "KPKTree.h"

#import "NSString+Commands.h"

@interface KPKTestReference : XCTestCase
@property (strong) KPKTree *tree;
@property (weak) KPKEntry *entry1;
@property (weak) KPKEntry *entry2;

@end

@implementation KPKTestReference

- (void)setUp {
  self.tree = [[KPKTree alloc] init];
  
  self.tree.root = [[KPKGroup alloc] init];
  self.tree.root.name = @"Root";
  
  KPKEntry *entry1 = [self.tree createEntry:self.tree.root];
  KPKEntry *entry2 = [self.tree createEntry:self.tree.root];
  [self.tree.root addEntry:entry1];
  [self.tree.root addEntry:entry2];
  self.entry1 = entry1;
  self.entry2 = entry2;
  
  self.entry2.url = @"-Entry2URL-";
  
  [super setUp];
}

- (void)tearDown {
  self.tree = nil;
  [super tearDown];
}

- (void)testCorrectUUIDReference {
  self.entry1.title = @"-Entry1Title-";
  self.entry2.title = [[NSString alloc] initWithFormat:@"Nothing{ref:t@i:%@}Changed", self.entry1.uuid.UUIDString];;
  self.entry2.url = @"-Entry2URL-";
  
  NSString *result = [self.entry2.title resolveReferencesWithTree:self.tree];
  XCTAssertTrue([result isEqualToString:@"Nothing-Entry1Title-Changed"], @"Replaced Strings should match");
}

- (void)testRecursiveUUIDReference{
  self.entry1.title = [[NSString alloc] initWithFormat:@"Title1{REF:A@i:%@}", self.entry2.uuid.UUIDString];
  self.entry2.title = [[NSString alloc] initWithFormat:@"Nothing{REF:t@I:%@}Changed", self.entry1.uuid.UUIDString];
  
  NSString *result = [self.entry2.title resolveReferencesWithTree:self.tree];
  XCTAssertTrue([result isEqualToString:@"NothingTitle1-Entry2URL-Changed"], @"Replaced Strings should match");
}

- (void)testReferncePasswordByTitle {
  self.entry1.title = [[NSString alloc] initWithFormat:@"Title1{REF:A@i:%@}", self.entry2.uuid.UUIDString];
  self.entry2.title = [[NSString alloc] initWithFormat:@"Nothing{REF:t@I:%@}Changed", self.entry1.uuid.UUIDString];
  
  
  NSString *result = [self.entry2.title resolveReferencesWithTree:self.tree];
  XCTAssertTrue([result isEqualToString:@"NothingTitle1-Entry2URL-Changed"], @"Replaced Strings should match");
}

- (void)testReferncePasswordByCustomAttribute {
  self.entry1.title = [[NSString alloc] initWithFormat:@"Title1{REF:T@i:%@}", self.entry2.uuid.UUIDString];
  self.entry2.title = @"Entry2Title";
  
  KPKAttribute *attribute1 = [[KPKAttribute alloc] initWithKey:@"Custom1" value:@"Value1"];
  [self.entry2 addCustomAttribute:attribute1];
  KPKAttribute *attribute2 = [[KPKAttribute alloc] initWithKey:@"Custom2" value:@"Value2"];
  [self.entry2 addCustomAttribute:attribute2];
}

- (void)testWrongRefernce {
  XCTFail(@"Missing Test");
}

- (void)testUnknownReference {
  XCTFail(@"Missing Test");
}

- (void)testMultipleMatchinReference {
  XCTFail(@"Missing Test");
}

@end
