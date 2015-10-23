//
//  NSError+Messages.m
//  MacPass
//
//  Created by Michael Starke on 04.09.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "NSError+Messages.h"

NSString *const MPErrorDomain       = @"com.hicknhack.macpass.error";

@implementation NSError (Messages)

- (NSString *)descriptionForErrorCode {
  return [NSString stringWithFormat:@"%@ (%ld)", self.localizedDescription, self.code ];
}

+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description {
  return [[NSError alloc] initWithDomain:MPErrorDomain code:code userInfo:@{ NSLocalizedDescriptionKey: description }];
}
@end
