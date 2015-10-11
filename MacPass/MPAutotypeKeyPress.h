//
//  MPAutotypeSpecialKey.h
//  MacPass
//
//  Created by Michael Starke on 24/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeCommand.h"

/**
 *  Autotype command to press a single key. Can be used with modifier keys as well
 */
@interface MPAutotypeKeyPress : MPAutotypeCommand

@property (assign) CGEventFlags modifierMask;
@property (assign) CGKeyCode keyCode;

- (instancetype)initWithModifierMask:(CGEventFlags)modiferMask keyCode:(CGKeyCode)code;
- (instancetype)initWithModifierMask:(CGEventFlags)modiferMask character:(NSString *)character;

@end
