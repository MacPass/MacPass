//
//  MPTestAutotypeDelay.m
//  MacPass
//
//  Created by Michael Starke on 28/12/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KeePassKit/KeePassKit.h>

#import "MPAutotypeContext.h"
#import "MPAutotypeDelay.h"

@interface MPTestAutotypeDelay : XCTestCase
@property (strong) KPKEntry *entry;
@end

@implementation MPTestAutotypeDelay

- (void)setUp {
  [super setUp];
  self.entry = [[KPKEntry alloc] init];
  self.entry.title = @"Title";
  self.entry.url = @"www.myurl.com";
  self.entry.username = @"Username";
  self.entry.password = @"Password";
}

- (void)tearDown {
  [super tearDown];
}

- (void)testLocalDelayCommands {
  /* Command 1 */
  MPAutotypeContext *context = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:@"{DELAY 200}"];
  NSArray *commands = [MPAutotypeCommand commandsForContext:context];
  
  XCTAssertEqual(commands.count, 1);
  /* {DELAY 200} */
  XCTAssertTrue([commands.firstObject isKindOfClass:[MPAutotypeDelay class]], @"Command is Delay command");
  MPAutotypeDelay *delay = commands.firstObject;
  XCTAssertEqual(delay.delay, 200, @"Delay is 200 ms");
  XCTAssertFalse(delay.isGlobal, @"Delay is no global delay");
}

- (void)testGlobalDelayCommands {
  /* Command 1 */
  MPAutotypeContext *context = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:@"{DELAY=200}"];
  NSArray *commands = [MPAutotypeCommand commandsForContext:context];
  
  XCTAssertEqual(commands.count, 1);
  /* {DELAY=200} */
  XCTAssertTrue([commands.firstObject isKindOfClass:MPAutotypeDelay.class], @"Command is Delay command");
  MPAutotypeDelay *delay = commands.firstObject;
  XCTAssertEqual(delay.delay, 200, @"Delay is 200 ms");
  XCTAssertTrue(delay.isGlobal, @"Delay is global delay");
}


- (void)testDelayExecution {
  MPAutotypeDelay *delay = [[MPAutotypeDelay alloc] initWithDelay:200];
  XCTestExpectation *expectation = [self expectationWithDescription:delay.description];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [delay execute];
    [expectation fulfill];
  });

  [self waitForExpectationsWithTimeout:(delay.delay/1000.0) handler:^(NSError *error) {
    if (error != nil) {
      NSLog(@"Error: %@", error.localizedDescription);
    }
  }];
}

@end
