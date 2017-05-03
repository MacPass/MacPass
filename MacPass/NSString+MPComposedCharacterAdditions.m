//
//  NSString+MPComposedCharacterLength.m
//  MacPass
//
//  Created by Michael Starke on 03.05.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
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

@end
