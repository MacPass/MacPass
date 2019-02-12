//
//  MPTestPluginVersion.m
//  MacPassTests
//
//  Created by Michael Starke on 05.10.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MPPluginVersionComparator.h"

@interface MPTestPluginVersion : XCTestCase

@end

@implementation MPTestPluginVersion

- (void)testSegmentClasification {
  XCTAssertEqual([MPPluginVersionComparator typeOfCharacter:@"1"], kMPVersionCharacterTypeNumeric);
  XCTAssertEqual([MPPluginVersionComparator typeOfCharacter:@"9"], kMPVersionCharacterTypeNumeric);
  XCTAssertEqual([MPPluginVersionComparator typeOfCharacter:@"*"], kMPVersionCharacterTypeWildcard);
  XCTAssertEqual([MPPluginVersionComparator typeOfCharacter:@"a"], kMPVersionCharacterTypeString);
  XCTAssertEqual([MPPluginVersionComparator typeOfCharacter:@"x"], kMPVersionCharacterTypeString);
  XCTAssertEqual([MPPluginVersionComparator typeOfCharacter:@"Ñ"], kMPVersionCharacterTypeString);
  XCTAssertEqual([MPPluginVersionComparator typeOfCharacter:@"."], kMPVersionCharacterTypeSeparator);
  XCTAssertEqual([MPPluginVersionComparator typeOfCharacter:@"-"], kMPVersionCharacterTypeSeparator);
  XCTAssertEqual([MPPluginVersionComparator typeOfCharacter:@":"], kMPVersionCharacterTypeSeparator);
  XCTAssertEqual([MPPluginVersionComparator typeOfCharacter:@"!"], kMPVersionCharacterTypeSeparator);
  
}

- (void)testVersionSplitting {
  
  NSArray *data = @[
                    @"10.1.99",       @[@"10", @".", @"1", @".", @"99"],
                    @"0.152",         @[@"0", @".", @"152"],
                    @"1.1.1beta",     @[@"1", @".", @"1", @".", @"1", @"beta"],
                    @"beta2.0",       @[@"beta", @"2", @".", @"0"],
                    @"*.*.1",         @[@"*", @".", @"*", @".", @"1"],
                    @"1-*",           @[@"1", @"-", @"*"],
                    @"1-1-1",         @[@"1", @"-", @"1", @"-", @"1"]
                    ];
  for(NSUInteger index = 0; index < data.count; index += 2 ) {
    NSString *versionString = data[index];
    NSArray *versionParts = data[index+1];
    XCTAssertEqualObjects([MPPluginVersionComparator splitVersionString:versionString], versionParts);
  }
}


- (void)testVersionCompare {
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"" toVersion:@""]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"*" toVersion:@"*"]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"1.0.1" toVersion:@"*"]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"*" toVersion:@"1.0.1"]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"1.*" toVersion:@"1.*"]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"1.1.*" toVersion:@"1.1.*"]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"1.1.1" toVersion:@"1.1.1"]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"1.0.1" toVersion:@"*"]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"0.10.*" toVersion:@"0.10.1"]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"10.*.1" toVersion:@"10.99.*"]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"0.9.89" toVersion:@"0.9.89"]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"1.*" toVersion:@"1.*.1"]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"1.*.2" toVersion:@"1.*"]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"1.0" toVersion:@"1."]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"1.0" toVersion:@"1.0.0"]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"1.0" toVersion:@"1.0.0.0.0.0.0.0"]);
  XCTAssertEqual(NSOrderedSame, [MPPluginVersionComparator compareVersion:@"1.0.*" toVersion:@"1.0"]);
  XCTAssertEqual(NSOrderedAscending, [MPPluginVersionComparator compareVersion:@"0.0.1" toVersion:@"0.0.2"]);
  XCTAssertEqual(NSOrderedAscending, [MPPluginVersionComparator compareVersion:@"0.0.1b" toVersion:@"0.0.1"]);
  XCTAssertEqual(NSOrderedAscending, [MPPluginVersionComparator compareVersion:@"1.10.10" toVersion:@"1.12.10"]);
  XCTAssertEqual(NSOrderedAscending, [MPPluginVersionComparator compareVersion:@"20.0.1" toVersion:@"20.1.0"]);
  XCTAssertEqual(NSOrderedAscending, [MPPluginVersionComparator compareVersion:@"1.1.1" toVersion:@"2.*"]);
  XCTAssertEqual(NSOrderedAscending, [MPPluginVersionComparator compareVersion:@"1.*" toVersion:@"2.0.*"]);
  XCTAssertEqual(NSOrderedDescending, [MPPluginVersionComparator compareVersion:@"2.1.1" toVersion:@"2.0.0"]);
  XCTAssertEqual(NSOrderedDescending, [MPPluginVersionComparator compareVersion:@"2.0.0" toVersion:@"2.0.0b"]);
  XCTAssertEqual(NSOrderedDescending, [MPPluginVersionComparator compareVersion:@"2.0.0" toVersion:@"2.0.0.0.0.beta"]);
  XCTAssertEqual(NSOrderedDescending, [MPPluginVersionComparator compareVersion:@"0.1.1" toVersion:@"0.1.0"]);
  XCTAssertEqual(NSOrderedDescending, [MPPluginVersionComparator compareVersion:@"1.2.*" toVersion:@"1.1.*"]);
  XCTAssertEqual(NSOrderedDescending, [MPPluginVersionComparator compareVersion:@"2.*" toVersion:@"1.*"]);
}

@end
