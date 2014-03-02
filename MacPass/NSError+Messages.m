//
//  NSError+Messages.m
//  MacPass
//
//  Created by Michael Starke on 04.09.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "NSError+Messages.h"
#import "KPKErrors.h"

@implementation NSError (Messages)

- (NSString *)descriptionForErrorCode {
  return [NSString stringWithFormat:@"%@ (%ld)", [self localizedDescription], [self code] ];
}
@end
