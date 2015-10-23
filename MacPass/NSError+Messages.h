//
//  NSError+Messages.h
//  MacPass
//
//  Created by Michael Starke on 04.09.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const MPErrorDomain;

@interface NSError (Messages)

+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description;

@property (nonatomic, readonly, copy) NSString *descriptionForErrorCode;

@end
