//
//  KPKFormat+MPUTIDetection.h
//  MacPass
//
//  Created by Michael Starke on 19/11/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "KPKFormat.h"

@interface KPKFormat (MPUTIDetection)

- (NSString *)typeForData:(NSData *)data;

- (NSString *)typeForContentOfURL:(NSURL *)url;

@end
