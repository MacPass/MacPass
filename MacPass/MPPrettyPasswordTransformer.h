//
//  MPPrettyPasswordTransformer.h
//  MacPass
//
//  Created by Michael Starke on 01.12.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

APPKIT_EXTERN NSString *const MPPrettyPasswordTransformerName;

@interface MPPrettyPasswordTransformer : NSValueTransformer

+ (void)registerTransformer;

@end
