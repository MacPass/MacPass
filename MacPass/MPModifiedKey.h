//
//  MPModifiedKey.h
//  MacPass
//
//  Created by Michael Starke on 26/01/2017.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
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

NS_INLINE BOOL MPIsValidModifiedKey(MPModifiedKey k) {
  return (k.keyCode == kMPUnknownKeyCode);
}

@interface NSValue(NSValueMPModifiedKeyExtensions)
@property (nonatomic, readonly, assign) MPModifiedKey modifiedKeyValue;
+ (instancetype)valueWithModifiedKey:(MPModifiedKey)key;
@end
