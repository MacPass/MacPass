//
//  KPKEntry+MPCustomAttributeProperties.m
//  MacPass
//
//  Created by Michael Starke on 03.09.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
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

#import "KPKEntry+MPCustomAttributeProperties.h"
#import <objc/runtime.h>

NSString *const MPCustomAttributePropertyPrefix = @"mp_valueForCustomAttribute";

@implementation KPKEntry (MPCustomAttributeProperties)

// generic getter
static id propertyIMP(id self, SEL _cmd) {
  NSString *propertyKey = [NSStringFromSelector(_cmd) substringFromIndex:MPCustomAttributePropertyPrefix.length];
  return [self valueForAttributeWithKey:propertyKey];
}


+ (BOOL)resolveInstanceMethod:(SEL)aSEL {
  if ([NSStringFromSelector(aSEL) hasPrefix:MPCustomAttributePropertyPrefix]) {
    class_addMethod(self.class, aSEL,(IMP)propertyIMP, "@@:");
    return YES;
  }
  return [super resolveInstanceMethod:aSEL];
}

@end
