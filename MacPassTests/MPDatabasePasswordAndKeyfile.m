//
//  MPDatabasePasswordAndKeyfile.m
//  MacPass
//
//  Created by Michael Starke on 11.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//


#import <XCTest/XCTest.h>

#import "MPDocument.h"
#import "KeePassKit/KeePassKit.h"

@interface MPDatabasePasswordAndKeyfile : XCTestCase {
  MPDocument *_database;
}
@end

@implementation MPDatabasePasswordAndKeyfile

- (void)setUp {
  _database = [[MPDocument alloc] init];
}

- (void)tearDown {
  _database = nil;
}

- (void)testSetPassword {
  XCTAssertNil(_database.compositeKey, @"New database should not have a composite key");
  XCTAssertTrue([_database changePassword:@"password" keyFileURL:nil], @"Setting the Password should succeed");
  XCTAssertFalse([_database changePassword:nil keyFileURL:nil], @"resetting the password and key to nil should not work");
}

- (void)testSetKeyfile {/*
  STAssertTrue([_database.password length] == 0, @"Password should not be set");
  STAssertNil(_database.key, @"Keyfile should not be set");
  STAssertFalse(_database.hasPasswordOrKey, @"Database without keyfile is not secure");
  _database.key = [NSURL URLWithString:@"noKeyFile"];
  STAssertTrue(_database.hasPasswordOrKey, @"Database with keyfile is secured");
  _database.key = nil;
  STAssertFalse(_database.hasPasswordOrKey, @"Database with removed keyfile is not secure anymore");*/
}


@end
