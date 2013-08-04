//
//  MPUniqueCharactersFormatter.m
//  MacPass
//
//  Created by Michael Starke on 28.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
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
