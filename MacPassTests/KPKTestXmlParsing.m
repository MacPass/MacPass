//
//  KPKTestXmlParsing.m
//  MacPass
//
//  Created by Michael Starke on 03.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKTestXmlParsing.h"
#import "KPKXmlTreeReader.h"
#import "KPKErrors.h"

#import "DDXMLDocument.h"

@implementation KPKTestXmlParsing

- (void)testEmptyXmlFile {
  DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:@"" options:0 error:NULL];
  KPKXmlTreeReader *reader = [[KPKXmlTreeReader alloc] initWithData:[document XMLData] headerReader:nil];
  NSError *error;
  KPKTree *tree = [reader tree:&error];
  STAssertNil(tree, @"No Tree form emptry data");
  STAssertNotNil(error, @"Error Object should be provided");
  STAssertTrue([error code] == KPKErrorNoData, @"Error Code should be No Data");
}

- (void)testNoNodeXmlFile {
  DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><root></root>" options:0 error:NULL];
  KPKXmlTreeReader *reader = [[KPKXmlTreeReader alloc] initWithData:[document XMLData] headerReader:nil];
  NSError *error;
  KPKTree *tree = [reader tree:&error];
  STAssertNil(tree, @"No Tree form emptry data");
  STAssertNotNil(error, @"Error Object should be provided");
  STAssertTrue([error code] == KPKErrorXMLKeePassFileElementMissing, @"Error Code should be KeePassFile root missing");
}

- (void)testNoRoodXmlFil {
  DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><KeePassFile><Root></Root></KeePassFile>" options:0 error:NULL];
  KPKXmlTreeReader *reader = [[KPKXmlTreeReader alloc] initWithData:[document XMLData] headerReader:nil];
  NSError *error;
  KPKTree *tree = [reader tree:&error];
  STAssertNil(tree, @"No Tree form emptry data");
  STAssertNotNil(error, @"Error Object should be provided");
  STAssertTrue([error code] == KPKErrorXMLRootElementMissing, @"Error Code should be KeePassFile root missing");
}

@end
