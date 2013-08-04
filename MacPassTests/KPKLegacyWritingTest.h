//
//  KPKLegacyWritingTest.h
//  MacPass
//
//  Created by Michael Starke on 02.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class KPKPassword;

@interface KPKLegacyWritingTest : SenTestCase {
  NSData *_data;
  KPKPassword *_password;
}

@end
