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

NSString *const MPCustomAttributePropertyPrefix = @"valueForCustomAttribute";

@implementation KPKEntry (MPCustomAttributeProperties)

/*- (void)forwardInvocation:(NSInvocation *)anInvocation {
  NSString *selector = NSStringFromSelector(anInvocation.selector);
  if([selector hasPrefix:MPCustomAttributePropertyPrefix]) {
    NSString *key = [selector substringFromIndex:MPCustomAttributePropertyPrefix.length];
    KPKAttribute *attribute = [self attributeWithKey:key];
    if(attribute) {
      anInvocation.selector = @selector(value);
      [anInvocation invokeWithTarget:attribute];
    }
    else {
      anInvocation.selector = @selector(_unkownCustomAttributeValue);
      [anInvocation invokeWithTarget:self];
    }
  }
  else [super forwardInvocation:anInvocation];
}*/

- (NSString *)_unkownCustomAttributeValue {
  return @"";
}

@end
