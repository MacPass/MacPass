//
//  MPNumericalInputFormatter.m
//  MacPass
//
//  Created by Michael Starke on 10.09.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPNumericalInputFormatter.h"

@implementation MPNumericalInputFormatter

static NSCharacterSet *_characterSet = nil;

- (id)init
{
  self = [super init];
  if (self) {
    _characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
  }
  return self;
}

- (NSString *)stringForObjectValue:(id)obj {
  if([obj isKindOfClass:[NSNumber class]]) {
    return [[NSString alloc] initWithFormat:@"%ld",[obj integerValue]];
  }
  return nil;
}

- (BOOL)getObjectValue:(out id *)obj forString:(NSString *)string errorDescription:(out NSString **)error {
  NSNumber *number = [[NSNumber alloc] initWithInteger:[string integerValue]];
  *obj = number;
  return YES;
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
              originalString:(NSString *)origString
       originalSelectedRange:(NSRange)origSelRange
            errorDescription:(NSString **)error {
  NSRange range = [*partialStringPtr rangeOfCharacterFromSet:_characterSet];
  return (range.location == NSNotFound);
}

@end
