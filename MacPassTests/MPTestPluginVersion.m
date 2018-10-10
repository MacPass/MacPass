//
//  MPTestPluginVersion.m
//  MacPassTests
//
//  Created by Michael Starke on 05.10.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MPPluginVersion.h"

@interface MPTestPluginVersion : XCTestCase

@end

@implementation MPTestPluginVersion

- (void)testVersionExtraction {
  MPPluginVersion *version = [[MPPluginVersion alloc] initWithVersionString:@"1."];
  XCTAssertEqualObjects(@"1", version.mayorVersion);
  XCTAssertEqualObjects(@"0", version.minorVersion);
  XCTAssertEqualObjects(@"0", version.patchVersion);
  XCTAssertEqualObjects(@"1.0.0", version.versionString);

  version = [[MPPluginVersion alloc] initWithVersionString:@"0.5"];
  XCTAssertEqualObjects(@"0", version.mayorVersion);
  XCTAssertEqualObjects(@"5", version.minorVersion);
  XCTAssertEqualObjects(@"0", version.patchVersion);
  XCTAssertEqualObjects(@"0.5.0", version.versionString);

  version = [[MPPluginVersion alloc] initWithVersionString:@".5"];
  XCTAssertEqualObjects(@"0", version.mayorVersion);
  XCTAssertEqualObjects(@"5", version.minorVersion);
  XCTAssertEqualObjects(@"0", version.patchVersion);
  XCTAssertEqualObjects(@"0.5.0", version.versionString);

  version = [[MPPluginVersion alloc] initWithVersionString:@"5"];
  XCTAssertEqualObjects(@"5", version.mayorVersion);
  XCTAssertEqualObjects(@"0", version.minorVersion);
  XCTAssertEqualObjects(@"0", version.patchVersion);
  XCTAssertEqualObjects(@"5.0.0", version.versionString);
  
  version = [[MPPluginVersion alloc] initWithVersionString:@".1."];
  XCTAssertEqualObjects(@"0", version.mayorVersion);
  XCTAssertEqualObjects(@"1", version.minorVersion);
  XCTAssertEqualObjects(@"0", version.patchVersion);
  XCTAssertEqualObjects(@"0.1.0", version.versionString);
  
  version = [[MPPluginVersion alloc] initWithVersionString:@".1.1"];
  XCTAssertEqualObjects(@"0", version.mayorVersion);
  XCTAssertEqualObjects(@"1", version.minorVersion);
  XCTAssertEqualObjects(@"1", version.patchVersion);
  XCTAssertEqualObjects(@"0.1.1", version.versionString);

  version = [[MPPluginVersion alloc] initWithVersionString:@"..1"];
  XCTAssertEqualObjects(@"0", version.mayorVersion);
  XCTAssertEqualObjects(@"0", version.minorVersion);
  XCTAssertEqualObjects(@"1", version.patchVersion);
  XCTAssertEqualObjects(@"0.0.1", version.versionString);

  version = [[MPPluginVersion alloc] initWithVersionString:@"1.0.0"];
  XCTAssertEqualObjects(@"1", version.mayorVersion);
  XCTAssertEqualObjects(@"0", version.minorVersion);
  XCTAssertEqualObjects(@"0", version.patchVersion);
  XCTAssertEqualObjects(@"1.0.0", version.versionString);

  version = [[MPPluginVersion alloc] initWithVersionString:@"0.1.0"];
  XCTAssertEqualObjects(@"0", version.mayorVersion);
  XCTAssertEqualObjects(@"1", version.minorVersion);
  XCTAssertEqualObjects(@"0", version.patchVersion);
  XCTAssertEqualObjects(@"0.1.0", version.versionString);

  version = [[MPPluginVersion alloc] initWithVersionString:@"1.1.1"];
  XCTAssertEqualObjects(@"1", version.mayorVersion);
  XCTAssertEqualObjects(@"1", version.minorVersion);
  XCTAssertEqualObjects(@"1", version.patchVersion);
  XCTAssertEqualObjects(@"1.1.1", version.versionString);

  version = [[MPPluginVersion alloc] initWithVersionString:@"0.0.5"];
  XCTAssertEqualObjects(@"0", version.mayorVersion);
  XCTAssertEqualObjects(@"0", version.minorVersion);
  XCTAssertEqualObjects(@"5", version.patchVersion);
  XCTAssertEqualObjects(@"0.0.5", version.versionString);

  version = [[MPPluginVersion alloc] initWithVersionString:@"1.0.3"];
  XCTAssertEqualObjects(@"1", version.mayorVersion);
  XCTAssertEqualObjects(@"0", version.minorVersion);
  XCTAssertEqualObjects(@"3", version.patchVersion);
  XCTAssertEqualObjects(@"1.0.3", version.versionString);

  version = [[MPPluginVersion alloc] initWithVersionString:@"0.1.4"];
  XCTAssertEqualObjects(@"0", version.mayorVersion);
  XCTAssertEqualObjects(@"1", version.minorVersion);
  XCTAssertEqualObjects(@"4", version.patchVersion);
  XCTAssertEqualObjects(@"0.1.4", version.versionString);

  version = [[MPPluginVersion alloc] initWithVersionString:@"0.1.*"];
  XCTAssertEqualObjects(@"0", version.mayorVersion);
  XCTAssertEqualObjects(@"1", version.minorVersion);
  XCTAssertEqualObjects(@"*", version.patchVersion);
  XCTAssertEqualObjects(@"0.1.*", version.versionString);
  
  version = [[MPPluginVersion alloc] initWithVersionString:@"*.1.0"];
  XCTAssertEqualObjects(@"*", version.mayorVersion);
  XCTAssertEqualObjects(@"*", version.minorVersion);
  XCTAssertEqualObjects(@"*", version.patchVersion);
  XCTAssertEqualObjects(@"*.*.*", version.versionString);
  
  version = [[MPPluginVersion alloc] initWithVersionString:@"1.*.0"];
  XCTAssertEqualObjects(@"1", version.mayorVersion);
  XCTAssertEqualObjects(@"*", version.minorVersion);
  XCTAssertEqualObjects(@"*", version.patchVersion);
  XCTAssertEqualObjects(@"1.*.*", version.versionString);
}

- (void)testeVersionCompare {
  
  NSArray *data = @[
                       @[ @"*",       @"*",       @(NSOrderedSame)],
                       @[ @"1.0.1",   @"*",       @(NSOrderedSame)],
                       @[ @"*",       @"1.0.1",   @(NSOrderedSame)],
                       @[ @"1.*",     @"1.*",     @(NSOrderedSame)],
                       @[ @"1.1.*",   @"1.1.*",   @(NSOrderedSame)],
                       @[ @"1.1.1",   @"1.1.1",   @(NSOrderedSame)],
                       @[ @"1.0.1",   @"*",       @(NSOrderedSame)],
                       @[ @"0.10.*",  @"0.10.1",  @(NSOrderedSame)],
                       @[ @"10.*.1",  @"10.99.*", @(NSOrderedSame)],
                       @[ @"0.9.89",  @"0.9.89",  @(NSOrderedSame)],
                       @[ @"0.0.1",   @"0.0.2",   @(NSOrderedAscending)],
                       @[ @"1.10.10", @"1.12.10", @(NSOrderedAscending)],
                       @[ @"20.0.1",  @"20.1.0",  @(NSOrderedAscending)],
                       @[ @"1.1.1",   @"2.*",     @(NSOrderedAscending)],
                       @[ @"1.*",     @"2.0.*",   @(NSOrderedAscending)],
                       @[ @"2.1.1",   @"2.0.0",   @(NSOrderedDescending)],
                       @[ @"0.1.1",   @"0.1.0",   @(NSOrderedDescending)],
                       @[ @"1.2.*",   @"1.1.*",   @(NSOrderedDescending)],
                       @[ @"2.*",     @"1.*",     @(NSOrderedDescending)]
                       ];
  for(NSUInteger index = 0; index < data.count; index++) {
    NSArray *set = data[index];
    MPPluginVersion *versionA = [[MPPluginVersion alloc] initWithVersionString:set[0]];
    MPPluginVersion *versionB = [[MPPluginVersion alloc] initWithVersionString:set[1]];
    NSComparisonResult result = [set[2] integerValue];
    XCTAssertEqual(result, [versionA compare:versionB]);
  }
  
}

@end
