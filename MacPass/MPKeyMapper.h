//
//  MPKeyMapper.h
//  MacPass
//
//  Created by Michael Starke on 07.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN uint16_t const kMPUnknownKeyCode;

typedef struct {
  CGEventFlags modifier;
  CGKeyCode keyCode;
} MPModifiedKey;

NS_INLINE MPModifiedKey MPMakeModifiedKey(CGEventFlags modifier, CGKeyCode keyCode) {
  MPModifiedKey k;
  k.keyCode = keyCode;
  k.modifier = modifier;
  return k;
}

@interface MPKeyMapper : NSObject

/**
 *  Retrieves the string representation with the current keyboard mapping for the keycode
 *
 *  @param keyCode The virtual keycode to be pressed
 *  @param modifier State of modifier flags being pressed with the key
 *  @return NSString containing the current mapping for the keyCode
 */
+ (NSString *)stringForKey:(CGKeyCode)keyCode;
+ (NSString *)stringForModifiedKey:(MPModifiedKey)modifiedKey;

/**
 *  Determines the modifiedkey (if possible) for the character. Modifiers might be needed
 *
 *  @param character NSString with a single character to be transformed
 *  @param modifier pointer to a modifer structure to return the modifer to use with the key code for the character
 *  @return ModifiedKey if one was found. If none is found, the returned modifiedKey.keyCode has the value kMPUnkonwKeyCode.
 */
+ (MPModifiedKey)modifiedKeyForCharacter:(NSString *)character;

@end
