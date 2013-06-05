//
//  MPUppercaseStringValueTransformer.h
//  MacPass
//
//  Created by Michael Starke on 03.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

APPKIT_EXTERN NSString *const MPUppsercaseStringValueTransformerName;

#import <Foundation/Foundation.h>

@interface MPUppercaseStringValueTransformer : NSValueTransformer

+ (void)registerTransformer;

@end
