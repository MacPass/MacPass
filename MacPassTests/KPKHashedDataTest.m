//
//  KPKHashedDataTest.m
//  MacPass
//
//  Created by Michael Starke on 08.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKHashedDataTest.h"
#import "NSData+HashedData.h"
#import "NSData+Random.h"

@implementation KPKHashedDataTest

- (void)testHashedData {
  
  NSData *data = [NSData dataWithRandomBytes:10000];
  NSData *hashedData = [data hashedDataWithBlockSize:512];
  NSData *unhashedData = [hashedData unhashedData];
  STAssertTrue([unhashedData isEqualToData:data], @"Data needs to be the same after hashing and unhashing");
}

@end
