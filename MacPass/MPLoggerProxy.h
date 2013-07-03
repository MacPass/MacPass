//
//  MPLoggerProxy.h
//  MacPass
//
//  Created by michael starke on 26.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPLoggerProxy : NSObject
@property (strong) id original;

- (id)initWithOriginal:(id) value;

@end
