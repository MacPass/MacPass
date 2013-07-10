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
  _databaseV3 = [[MPDocument alloc] initWithVersion:MPDatabaseVersion3];
  _databaseV4 = [[MPDocument alloc] initWithVersion:MPDatabaseVersion4];
}

- (void)tearDown {
  _databaseV3 = nil;
  _databaseV4 = nil;
}

- (void)testSetPassword {
  STAssertTrue([_databaseV3.password length] == 0, @"Password should not be set");
  STAssertNil(_databaseV3.key, @"Keyfile should not be set");
  STAssertFalse(_databaseV3.isSecured, @"Database without password is not secure");
  _databaseV3.password = @"test";
  STAssertTrue([_databaseV3.password isEqualToString:@"test"], @"Password should be set");
  STAssertTrue(_databaseV3.isSecured, @"Database with password is secured");
  _databaseV3.password = nil;
  STAssertFalse(_databaseV3.isSecured, @"Database with removed password is not secure anymore");
}

- (void)testSetKeyfile {
  STAssertTrue([_databaseV3.password length] == 0, @"Password should not be set");
  STAssertNil(_databaseV3.key, @"Keyfile should not be set");
  STAssertFalse(_databaseV3.isSecured, @"Database without keyfile is not secure");
  _databaseV3.key = [NSURL URLWithString:@"noKeyFile"];
  STAssertTrue(_databaseV3.isSecured, @"Database with keyfile is secured");
  _databaseV3.key = nil;
  STAssertFalse(_databaseV3.isSecured, @"Database with removed keyfile is not secure anymore");
}


@end
