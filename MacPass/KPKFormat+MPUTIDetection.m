//
//  KPKFormat+MPUTIDetection.m
//  MacPass
//
//  Created by Michael Starke on 19/11/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
  KPKFileVersion fileVersion = [self fileVersionForData:data];
  return [self _typeToUTIdictionary][@(fileVersion.format)];
}

- (NSString *)typeForContentOfURL:(NSURL *)url {
  NSData *data = [NSData dataWithContentsOfURL:url];
  return [self typeForData:data];
}

@end
