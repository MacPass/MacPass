//
//  MPKeyMapper.h
//  MacPass
//
//  Created by Michael Starke on 07.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN uint16_t const kMPUnknownKeyCode;

@interface MPKeyMapper : NSObject

/**
 *  Retrieves the string representation with the current keyboard mapping for the keycode
 *
 *  @param keyCode The virtual keycode to be pressed
 *  @return NSString containing the current mapping for the keyCode
 */
+ (NSString *)stringForKey:(CGKeyCode)keyCode;

/**
 *  Determines the keyCode (if possible) for the charater
 *
 *  @param character NSString with a single character to be transformed
 *  @return virtual Keycode for the supplied string. If none is found, kMPUnkonwKeyCode is returned
 */
+ (CGKeyCode)keyCodeForCharacter:(NSString *)character;

@end
