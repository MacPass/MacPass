//
//  MPKeyMapper.h
//  MacPass
//
//  Created by Michael Starke on 07.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Foundation/Foundation.h>
#import "MPModifiedKey.h"

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
