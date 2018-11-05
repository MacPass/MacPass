//
//  NSString+MPComposedCharacterLength.m
//  MacPass
//
//  Created by Michael Starke on 03.05.17.
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

#import "NSString+MPComposedCharacterAdditions.h"

@implementation NSString (MPComposedCharacterAdditions)

- (NSUInteger)composedCharacterLength {
  NSUInteger __block actualLength = 0;
  [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                           options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                             actualLength++;
                           }];
  return actualLength;
}

- (NSArray<NSValue *> *)composedCharacterRanges {
  __block NSMutableArray *ranges = [[NSMutableArray alloc] initWithCapacity:self.length];
  [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                             options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                               [ranges addObject:[NSValue valueWithRange:substringRange]];
                             }];
  return [ranges copy];
}

- (NSString *)composedCharacterAtIndex:(NSUInteger)index {
  NSArray <NSValue *> *ranges = self.composedCharacterRanges;
  if(index < ranges.count) {
    return [self substringWithRange:ranges[index].rangeValue];
  }
  return nil;
}

- (NSArray<NSString *> *)composedCharacters {
  __block NSMutableArray *characters = [[NSMutableArray alloc] init];
  [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                           options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                             if(substring) {
                               [characters addObject:substring];
                             }
                           }];
  return [characters copy];
}


@end
