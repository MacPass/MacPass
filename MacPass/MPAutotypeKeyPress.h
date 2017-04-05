//
//  MPAutotypeSpecialKey.h
//  MacPass
//
//  Created by Michael Starke on 24/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeCommand.h"
#import "MPModifiedKey.h"
/**
 *  Autotype command to press a single key. Can be used with modifier keys as well
 */
@interface MPAutotypeKeyPress : MPAutotypeCommand

@property (readonly, assign) MPModifiedKey key;

- (instancetype)initWithModifiedKey:(MPModifiedKey)key;
- (instancetype)initWithModifierMask:(CGEventFlags)modiferMask character:(NSString *)character;

@end
