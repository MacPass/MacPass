//
//  MPAutotypeSpecialKey.h
//  MacPass
//
//  Created by Michael Starke on 24/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
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

#import "MPAutotypeCommand.h"
#import "MPModifiedKey.h"
/**
 *  Autotype command to press a single key. Can be used with modifier keys as well
 */
@interface MPAutotypeKeyPress : MPAutotypeCommand

@property (readonly, assign) MPModifiedKey key;
@property (readonly, copy) NSString *character;


/**
 Initializes a command with the given keycode and modifier mask
 MacPass will update the modifiers according to user preferences to accomodate
 for command-control differences between windows/linux and macOS
 
 The virtual key code is used as-is without and re-mapping.
 
 This will result in unexpected behaviour for keyboard layouts other tha us-ascii
 
 use initWithModifierMask:character to initalized the key press command to ensurue the
 correct character is typed regardless of the keyboard layout

 @param key The modified key to be pressed
 @return The press key command with the supplied argurments set
 */
- (instancetype)initWithModifiedKey:(MPModifiedKey)key;

/**
 Initalizes a command with the given modifier mask and the character to be typed.
 A suitable keycode and modifier

 @param modiferMask Modifiers mask to use when typing the character
 @param character The character to be typed. It is ecnoureaded to use single characters
 @return The type command to type the supplied character with the given modifiers
 */
- (instancetype)initWithModifierMask:(CGEventFlags)modiferMask character:(NSString *)character;

@end
