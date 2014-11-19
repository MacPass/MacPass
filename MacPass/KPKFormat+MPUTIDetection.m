//
//  KPKFormat+MPUTIDetection.m
//  MacPass
//
//  Created by Michael Starke on 19/11/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "KPKFormat+MPUTIDetection.h"

#import "MPConstants.h"

@implementation KPKFormat (MPUTIDetection)

- (NSDictionary *)_typeToUTIdictionary {
  static NSDictionary *typeToUTI;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    typeToUTI = @{
                  @(KPKLegacyVersion) : MPLegacyDocumentUTI,
                  @(KPKXmlVersion) : MPXMLDocumentUTI
                  };
  });
  return typeToUTI;
}

- (NSString *)typeForData:(NSData *)data {
  KPKVersion version = [self databaseVersionForData:data];
  return [self _typeToUTIdictionary][@(version)];
}

- (NSString *)typeForContentOfURL:(NSURL *)url {
  NSData *data = [NSData dataWithContentsOfURL:url];
  return [self typeForData:data];
}

@end
