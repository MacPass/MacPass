//
//  MPToken.h
//  MacPass
//
//  Created by Michael Starke on 07.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPToken : NSObject

@property (readonly, copy) NSString *value;

+ (NSArray<MPToken *> *)tokenizeString:(NSString *)string;
- (instancetype)initWithValue:(NSString *)value NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
