//
//  MPTextEntryProxy.m
//  MacPass
//
//  Created by Michael Starke on 07/03/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <KeePassKit/KeePassKit.h>

#import "MPEntryProxy.h"

@interface MPTextEntryProxy : XCTestCase
@property (strong) KPKEntry *entry;
@property (strong) MPEntryProxy *proxy;

@end

@implementation MPTextEntryProxy

- (void)setUp {
  [super setUp];
  self.entry = [[KPKEntry alloc] init];
  self.entry.title = @"Entry Title";
  self.entry.url = @"http://www.internet.com";
  self.entry.password = @"1234";
  self.entry.username = @"Entry Username";
  self.entry.autotype.defaultKeystrokeSequence = @"{TAB 3}";
  
  self.proxy = [[MPEntryProxy alloc] initWithEntry:self.entry];
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testMethodForwarding {
  NSString *newPassword = @"new password";
  NSString *newKeystrokes = @"{ENTER 3}";
  [((id)self.proxy) setPassword:newPassword];
  XCTAssertEqualObjects(self.entry.password, newPassword, @"Proxy sets password on entry!");

  [((id)self.proxy) autotype].defaultKeystrokeSequence= newKeystrokes;
  XCTAssertEqualObjects(self.entry.autotype.defaultKeystrokeSequence, newKeystrokes, @"Proxy sets default keystroke sequence on entry autotype!");
}

@end
