//
//  MPTestKeyMapper.m
//  MacPass
//
//  Created by Michael Starke on 18/01/2017.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Carbon/Carbon.h>

#import "MPKeyMapper.h"


@interface MPTestKeyMapper : XCTestCase

@end

@implementation MPTestKeyMapper

- (void)testKeyMapper {
  
  /*
   We could set certain keyboard layouts to run this test invariantly
   The simpler aproach is to go full circle to check if the desired character is the actual character we get
   */
  NSString *test = @"aB(]©®@ﬂ~±»";
  
  [test enumerateSubstringsInRange:NSMakeRange(0, test.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
    /* we only support non-composed characters*/
    if(substring.length == 1) {
      MPModifiedKey key = [MPKeyMapper modifiedKeyForCharacter:substring];
      NSString *result = [MPKeyMapper stringForModifiedKey:key];
      XCTAssertEqualObjects(substring, result);
    }    
  }];
}

@end
