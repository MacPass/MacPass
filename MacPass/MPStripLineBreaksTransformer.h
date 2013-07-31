//
//  MPStripLineBreaksTransformer.h
//  MacPass
//
//  Created by Michael Starke on 31.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const MPStripLineBreaksTransformerName;

@interface MPStripLineBreaksTransformer : NSValueTransformer

+ (void)registerTransformer;

@end
