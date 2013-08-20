//
//  KPKTestXmlWriting.m
//  MacPass
//
//  Created by Michael Starke on 20.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKTestXmlWriting.h"
#import "KPKPassword.h"
#import "KPKTree+Serializing.h"

@implementation KPKTestXmlWriting

- (void)testXmlWriting {
  NSData *data = [self _loadTestDataBase:@"CustomIcon_Password_1234" extension:@"kdbx"];
  NSError *error;
  KPKPassword *password = [[KPKPassword alloc] initWithPassword:@"1234" key:nil];
  KPKTree *tree = [[KPKTree alloc] initWithData:data password:password error:&error];
  error = nil;
  NSData *saveData = [tree encryptWithPassword:password forVersion:KPKXmlVersion error:&error];
  //[saveData writeToFile:@"CustomIcon_Password_1234_save.kdbx" atomically:YES];
}

- (NSData *)_loadTestDataBase:(NSString *)name extension:(NSString *)extension {
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSURL *url = [myBundle URLForResource:name withExtension:extension];
  return [NSData dataWithContentsOfURL:url];
}

@end
