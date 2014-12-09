//
//  MPDatabaseSearch.m
//  MacPass
//
//  Created by Michael Starke on 09/12/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "KPKTree.h"
#import "KPKGroup.h"
#import "KPKEntry.h"

@interface MPDatabaseSearch : XCTestCase

@property (strong) KPKTree *tree;
@property (weak) KPKGroup *includedGroup;
@property (weak) KPKGroup *inheritingGroup;
@property (weak) KPKGroup *excludedGroup;
@property (weak) KPKEntry *entry1;
@property (weak) KPKEntry *entry2;
@property (weak) KPKEntry *entry3;

@end

@implementation MPDatabaseSearch

- (void)setUp {
  [super setUp];
  self.tree = [[KPKTree alloc] init];
  self.tree.root = [[KPKGroup alloc] init];
  
  /* FIXEM weak! */
  self.inheritingGroup = [self.tree createGroup:self.tree.root];
  self.includedGroup = [self.tree createGroup:self.tree.root];
  self.excludedGroup = [self.tree createGroup:self.tree.root];
  self.inheritingGroup.isAutoTypeEnabled = KPKInherit;
  self.includedGroup.isAutoTypeEnabled = KPKInheritYES;
  self.excludedGroup.isAutoTypeEnabled = KPKInheritNO;
  
  self.entry1 = [self.tree createEntry:self.includedGroup];
  self.entry2 = [self.tree createEntry:self.inheritingGroup];
  self.entry3 = [self.tree createEntry:self.excludedGroup];
  self.entry1.title = @"entry1";
  self.entry2.title = @"entry2";
  self.entry3.title = @"entry3";
}

- (void)tearDown {
  self.tree = nil;
  [super tearDown];
}

- (void)testSearch {
}

@end
