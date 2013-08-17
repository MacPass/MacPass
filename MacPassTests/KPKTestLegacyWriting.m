//
//  KPKLegacyWritingTest.m
//  MacPass
//
//  Created by Michael Starke on 02.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKTestLegacyWriting.h"


#import "KPKPassword.h"
#import "KPKTree+Serializing.h"

@implementation KPKTestLegacyWriting

- (void)setUp {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:@"Test_Password_1234" withExtension:@"kdb"];
  _data = [NSData dataWithContentsOfURL:url];
  _password = [[KPKPassword alloc] initWithPassword:@"1234" key:nil];
}

- (void)tearDown {
  _data = nil;
  _password = nil;
}

- (void)testWriting {
  NSError *error = nil;
  KPKTree *tree = [[KPKTree alloc] initWithData:_data password:_password error:&error];
  NSData *data = [tree encryptWithPassword:_password forVersion:KPKLegacyVersion error:&error];
}


@end
