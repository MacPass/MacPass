//
//  MPTestNodeDelegate.m
//  MacPass
//
//  Created by Michael Starke on 13/06/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KeePassKit/KeePassKit.h>

@interface MPDummyDelegate : NSObject <KPKModificationDelegate>

@property (strong) NSMutableSet<NSUUID *> *uuids;

@end

@implementation MPDummyDelegate

- (instancetype)init {
  self = [super init];
  if(self) {
    self.uuids = [[NSMutableSet alloc] init];
  }
  return self;
}

- (void)willModifyNode:(KPKNode *)node {
  if(node.asGroup || ! node.asEntry) {
    NSLog(@"Node is no entry, no need to do anything!");
    return;
  }
  KPKEntry *entry = node.asEntry;
  if(![self.uuids containsObject:entry.uuid]) {
    [self.uuids addObject:entry.uuid];
     NSLog(@"First mutation for %@ detected. Pushin history", entry);
    [entry pushHistory];
  }
}

@end

@interface MPTestNodeDelegate : XCTestCase

@property (strong) KPKEntry *entry;
@property (strong) MPDummyDelegate *delegate;

@end

@implementation MPTestNodeDelegate

- (void)setUp {
  [super setUp];
  self.entry = [[KPKEntry alloc] init];
  self.entry.title = @"Entry Title";
  self.entry.url = @"http://www.internet.com";
  self.entry.password = @"1234";
  self.entry.username = @"Entry Username";
  self.entry.autotype.defaultKeystrokeSequence = @"{TAB 3}";
  
  self.delegate = [[MPDummyDelegate alloc] init];
  
  self.entry.delegate = self.delegate;
}

- (void)tearDown {
  [super tearDown];
}

- (void)testModificationDetection {
  XCTAssertTrue(self.entry.history.count == 0, @"No History entry is present on newly created entry!");
  self.entry.password = @"New Password";
  XCTAssertEqualObjects(self.entry.password, @"New Password", @"Password is set on entry!");
  XCTAssertTrue(self.entry.history.count == 1, @"Changin the password creates a history entry!");
  KPKEntry *historyEntry = self.entry.history.firstObject;
  XCTAssertEqualObjects(historyEntry.password, @"1234", @"Password on history entry did not change!");
}

@end
