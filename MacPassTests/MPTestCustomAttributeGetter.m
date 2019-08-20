//
//  MPTestCustomAttributeGetter.m
//  MacPassTests
//
//  Created by Michael Starke on 09.11.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KeePassKit/KeePassKit.h>

#import "KPKEntry+MPCustomAttributeProperties.h"

@interface MPTestCustomAttributeGetter : XCTestCase
@end

@implementation MPTestCustomAttributeGetter

- (void)setUp {
}

- (void)testValidCustomAttribute {
  KPKEntry *entry = [[KPKEntry alloc] init];
  KPKAttribute *attribute1 = [[KPKAttribute alloc] initWithKey:@"custom1" value:@"value1"];
  KPKAttribute *attribute2 = [[KPKAttribute alloc] initWithKey:@"custom2" value:@"value2"];
  [entry addCustomAttribute:attribute1];
  [entry addCustomAttribute:attribute2];
  
  SEL selector1 = NSSelectorFromString([MPCustomAttributePropertyPrefix stringByAppendingString:attribute1.key]);
  IMP imp1 = [entry methodForSelector:selector1];
  NSString *(*func1)(id, SEL, NSString*) = (void *)imp1;
  NSString *value1 = func1(entry, selector1 , attribute1.key);
  XCTAssertEqualObjects(value1, attribute1.value);

  SEL selector2 = NSSelectorFromString([MPCustomAttributePropertyPrefix stringByAppendingString:attribute2.key]);
  IMP imp2 = [entry methodForSelector:selector2];
  NSString *(*func2)(id, SEL, NSString*) = (void *)imp2;
  NSString *value2 = func2(entry, selector2, attribute2.key);
  XCTAssertEqualObjects(value2, attribute2.value);
}

- (void)testInvalidCustomAttribute {
  KPKEntry *entry = [[KPKEntry alloc] init];
  KPKAttribute *attribute1 = [[KPKAttribute alloc] initWithKey:@"custom1" value:@"value1"];
  KPKAttribute *attribute2 = [[KPKAttribute alloc] initWithKey:@"custom2" value:@"value2"];
  [entry addCustomAttribute:attribute1];
  [entry addCustomAttribute:attribute2];
  
  SEL selector = NSSelectorFromString([MPCustomAttributePropertyPrefix stringByAppendingString:@"novalidkey"]);
  IMP imp = [entry methodForSelector:selector];
  NSString *(*func)(id, SEL, NSString*) = (void *)imp;
  NSString *value = func(entry, selector, @"novalidkey");
  XCTAssertNil(value);

}



@end
