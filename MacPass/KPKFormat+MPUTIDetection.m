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
                  @(KPKDatabaseFormatKdb) : MPKdbDocumentUTI,
                  @(KPKDatabaseFormatKdbx) : MPKdbxDocumentUTI
                  };
  });
  return typeToUTI;
}

- (NSString *)typeForData:(NSData *)data {
  KPKFileInfo fileInfo = [self fileInfoForData:data];
  return [self _typeToUTIdictionary][@(fileInfo.format)];
}

- (NSString *)typeForContentOfURL:(NSURL *)url {
  NSData *data = [NSData dataWithContentsOfURL:url];
  return [self typeForData:data];
}

@end
