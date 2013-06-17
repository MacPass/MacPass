//
//  MPStringLengthValueTransformer.h
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

APPKIT_EXTERN NSString *const MPStringLengthValueTransformerName;

@interface MPStringLengthValueTransformer : NSValueTransformer

+ (void)registerTransformer;

@end
