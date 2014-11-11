//
//  KPKTestReference.m
//  MacPass
//
//  Created by Michael Starke on 15.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KPKTree.h"
#import "KPKGroup.h"
#import "KPKEntry.h"
#import "NSString+Commands.h"

@interface KPKTestReference : XCTestCase

@end

@implementation KPKTestReference

- (void)testCorrectUUIDReference {
  KPKTree *tree = [[KPKTree alloc] init];
  KPKGroup *group = [[KPKGroup alloc] init];
  KPKEntry *entry1 = [[KPKEntry alloc] init];
  KPKEntry *entry2 = [[KPKEntry alloc] init];
  entry1.title = @"-Entry1Title-";
  entry2.title = [[NSString alloc] initWithFormat:@"Nothing{ref:t@i:%@}Changed", entry1.uuid.UUIDString];;
  entry2.url = @"-Entry2URL-";
  
  [group addEntry:entry1];
  [group addEntry:entry2];
  tree.root = group;
  
  NSString *result = [entry2.title resolveReferencesWithTree:tree];
  XCTAssertTrue([result isEqualToString:@"Nothing-Entry1Title-Changed"], @"Replaced Strings should match");
}

- (void)testRecursiveUUIDReference{
  KPKTree *tree = [[KPKTree alloc] init];
  KPKGroup *group = [[KPKGroup alloc] init];
  KPKEntry *entry1 = [[KPKEntry alloc] init];
  KPKEntry *entry2 = [[KPKEntry alloc] init];
  entry1.title = [[NSString alloc] initWithFormat:@"Title1{REF:A@i:%@}", entry2.uuid.UUIDString];
  entry2.title = [[NSString alloc] initWithFormat:@"Nothing{REF:t@I:%@}Changed", entry1.uuid.UUIDString];
  entry2.url = @"-Entry2URL-";
  
  [group addEntry:entry1];
  [group addEntry:entry2];
  tree.root = group;
  
  NSString *result = [entry2.title resolveReferencesWithTree:tree];
  XCTAssertTrue([result isEqualToString:@"NothingTitle1-Entry2URL-Changed"], @"Replaced Strings should match");
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
