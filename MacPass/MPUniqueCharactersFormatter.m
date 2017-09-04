//
//  MPUniqueCharactersFormatter.m
//  MacPass
//
//  Created by Michael Starke on 28.07.13.
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

#import "MPUniqueCharactersFormatter.h"

@implementation MPUniqueCharactersFormatter

- (NSString *)stringForObjectValue:(id)obj {
  if([obj isKindOfClass:[NSString class]]) {
    return obj;
  }
  return nil;
}

- (BOOL)getObjectValue:(out id *)obj forString:(NSString *)string errorDescription:(out NSString **)error {
  *obj = string;
  return YES;
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
              originalString:(NSString *)origString
       originalSelectedRange:(NSRange)origSelRange
            errorDescription:(NSString **)error {
  NSInteger newLenght = [*partialStringPtr length];
  NSInteger oldLenght = [origString length];
  if( oldLenght == 0 || (newLenght < oldLenght)) {
    return YES;
  }
  
  NSCharacterSet *newCharacterSet = [NSCharacterSet characterSetWithCharactersInString:*partialStringPtr];
  NSCharacterSet *oldCharacterSet = [NSCharacterSet characterSetWithCharactersInString:origString];

  return ![oldCharacterSet isSupersetOfSet:newCharacterSet];
}

@end
