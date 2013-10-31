//
//  KPKXmlLoadingTest.h
//  MacPass
//
//  Created by Michael Starke on 23.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class KPKCompositeKey;

@interface KPKTestXmlLoading : SenTestCase {
@private
  NSData *_data;
  KPKCompositeKey *_password;
}

@end
