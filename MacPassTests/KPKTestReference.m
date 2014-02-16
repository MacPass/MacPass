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

- (void)testCorrectReference {
  KPKTree *tree = [[KPKTree alloc] init];
  KPKGroup *group = [[KPKGroup alloc] init];
  KPKEntry *entry1 = [[KPKEntry alloc] init];
  KPKEntry *entry2 = [[KPKEntry alloc] init];
  entry1.title = @"-Entry1Title-";
  NSString *title2 = [[NSString alloc] initWithFormat:@"Nothing{REF:T@I:%@}Changed", entry1.uuid.UUIDString];
  entry2.title = title2;
  entry2.url = @"-Entry2URL-";
  
  [group addEntry:entry1];
  [group addEntry:entry2];
  tree.root = group;
  
  NSString *result = [entry2.title resolveReferencesWithTree:tree];
  XCTAssertTrue([result isEqualToString:@"Nothing-Entry1Title-Changed"], @"Replaced Strings should match");
}

- (void)testRecursiveReference{
  KPKTree *tree = [[KPKTree alloc] init];
  KPKGroup *group = [[KPKGroup alloc] init];
  KPKEntry *entry1 = [[KPKEntry alloc] init];
  KPKEntry *entry2 = [[KPKEntry alloc] init];
  NSString *title1 = [[NSString alloc] initWithFormat:@"Title1{REF:A@I:%@}", entry2.uuid.UUIDString];
  entry1.title = title1; // References URL of entry 2
  NSString *title2 = [[NSString alloc] initWithFormat:@"Nothing{REF:T@I:%@}Changed", entry1.uuid.UUIDString];
  entry2.title = title2; // Refernces Title of entry 1
  entry2.url = @"-Entry2URL-";
  
  [group addEntry:entry1];
  [group addEntry:entry2];
  tree.root = group;
  
  NSString *result = [entry2.title resolveReferencesWithTree:tree];
  XCTAssertTrue([result isEqualToString:@"NothingTitle1-Entry2URL-Changed"], @"Replaced Strings should match");
}

- (void)testWrongRefernceFormat {
  XCTFail(@"Missing Test");
}

- (void)testUnknownReference {
  XCTFail(@"Missing Test");
}

- (void)testMultipleMatchinRefernce {
  XCTFail(@"Missing Test");
}

@end
