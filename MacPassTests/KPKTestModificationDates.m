//
//  KPKTestModificationDates.m
//  MacPass
//
//  Created by Michael Starke on 26/10/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KeePassKit.h"
#import "KeePassKit+Private.h"

@interface KPKTestModificationDates : XCTestCase

@property (strong) KPKTree *tree;
@property (weak) KPKGroup *group;
@property (weak) KPKEntry *entry;

@end

@implementation KPKTestModificationDates

- (void)setUp {
  [super setUp];
  self.tree = [[KPKTree alloc] init];
  self.tree.root = [[KPKGroup alloc] init];
  self.group = self.tree.root;
  [self.group addEntry:[[KPKEntry alloc] init]];
  self.entry = self.group.entries.firstObject;
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testEnableDisableModificationRecording {
  XCTAssertTrue(self.group.updateTiming, @"updateTiming is enabled for newly created groups!");
  XCTAssertTrue(self.entry.updateTiming, @"updateTiming is enabled for newly created entries!");
  self.group.updateTiming = NO;
  self.entry.updateTiming = NO;
  XCTAssertFalse(self.group.updateTiming, @"updateTiming is disabled!");
  XCTAssertFalse(self.entry.updateTiming, @"updateTiming is disabled!");
  self.group.updateTiming = YES;
  self.entry.updateTiming = YES;
  XCTAssertTrue(self.group.updateTiming, @"updateTiming is enabled!");
  XCTAssertTrue(self.entry.updateTiming, @"updateTiming is enabled!");
}

- (void)testGroupModificationDate {
  XCTFail(@"Missing Test");
}

- (void)testEntryModifiationDate {
  static NSString *const _kUpdatedString = @"Updated";

  for(NSString *key in [KPKFormat sharedFormat].entryDefaultKeys) {
    NSDate *before = [self.entry.timeInfo.modificationDate copy];
    [self.entry _setValue:_kUpdatedString forAttributeWithKey:key];
    NSComparisonResult compare = [before compare:self.entry.timeInfo.modificationDate];
    XCTAssertTrue(compare == NSOrderedAscending,@"Modification date has to be updated after modification");
  }
}
@end
