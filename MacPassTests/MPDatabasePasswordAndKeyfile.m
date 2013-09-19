//
//  MPDatabasePasswordAndKeyfile.m
//  MacPass
//
//  Created by Michael Starke on 11.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDatabasePasswordAndKeyfile.h"

#import "MPDocument.h"

@implementation MPDatabasePasswordAndKeyfile

- (void)setUp {
  _database = [[MPDocument alloc] init];
}

- (void)tearDown {
  _database = nil;
}

- (void)testSetPassword {
  STAssertTrue([_database.password length] == 0, @"Password should not be set");
  STAssertNil(_database.key, @"Keyfile should not be set");
  STAssertFalse(_database.hasPasswordOrKey, @"Database without password is not secure");
  _database.password = @"test";
  STAssertTrue([_database.password isEqualToString:@"test"], @"Password should be set");
  STAssertTrue(_database.hasPasswordOrKey, @"Database with password is secured");
  _database.password = nil;
  STAssertFalse(_database.hasPasswordOrKey, @"Database with removed password is not secure anymore");
}

- (void)testSetKeyfile {
  STAssertTrue([_database.password length] == 0, @"Password should not be set");
  STAssertNil(_database.key, @"Keyfile should not be set");
  STAssertFalse(_database.hasPasswordOrKey, @"Database without keyfile is not secure");
  _database.key = [NSURL URLWithString:@"noKeyFile"];
  STAssertTrue(_database.hasPasswordOrKey, @"Database with keyfile is secured");
  _database.key = nil;
  STAssertFalse(_database.hasPasswordOrKey, @"Database with removed keyfile is not secure anymore");
}


@end
