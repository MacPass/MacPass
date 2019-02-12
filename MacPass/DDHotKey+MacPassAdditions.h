//
//  DDHotKey+Coding.h
//  MacPass
//
//  Created by Michael Starke on 25/03/14.
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

#import "DDHotKeyCenter.h"

@interface DDHotKey (MPKeydata)

@property (readonly, copy) NSData *keyData;
@property (readonly, copy, class) NSData *defaultHotKeyData;

/**
 Use this method to retrieve the data, since deallocation of a hotkey unregisters it, this could yield unwanted behaviour!
 @return data for the default hot key.
*/
+ (NSData *)hotKeyDataWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags;

+ (instancetype)defaultHotKey;
+ (instancetype)defaultHotKeyWithTask:(DDHotKeyTask)task;
+ (instancetype)hotKeyWithKeyData:(NSData *)data task:(DDHotKeyTask)task;
+ (instancetype)hotKeyWithKeyData:(NSData *)data;

@end

@interface DDHotKey (MPValidation)

/*
 A hotkey is considered valid, if the key contains at least a modifier and a non-modifier key.
 For example Control+Alt is no valid hotkey, as it's missing a non-modifier. Control+Escape however is valid.

 @return YES if the hot key is a valid hotkey, NO otherwise
 */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@end
