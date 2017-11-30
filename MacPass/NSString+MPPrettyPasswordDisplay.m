//
//  NSString+MPPrettyPasswordDisplay.m
//  MacPass
//
//  Created by Michael Starke on 30.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "NSString+MPPrettyPasswordDisplay.h"

@implementation NSString (MPPrettyPasswordDisplay)

@dynamic passwordPrettified;

- (NSAttributedString *)passwordPrettified {
  NSMutableAttributedString *attributedPassword = [[NSMutableAttributedString alloc] initWithString:self];
  [self _setAttributesInString:attributedPassword];
  return [attributedPassword copy];
}

- (void)_setAttributesInString:(NSMutableAttributedString *)string {
  /* digits */
  NSArray <NSValue *> *digitRanges = [self rangesOfCharactersInSet:NSCharacterSet.decimalDigitCharacterSet];
  for(NSValue *rangeValue in digitRanges) {
    [string addAttribute:NSForegroundColorAttributeName value:NSColor.redColor range:rangeValue.rangeValue];
  }
  /* symbols */
  NSArray <NSValue *> *symbolRanges = [self rangesOfCharactersInSet:NSCharacterSet.symbolCharacterSet];
  for(NSValue *rangeValue in symbolRanges) {
    [string addAttribute:NSForegroundColorAttributeName value:NSColor.blueColor range:rangeValue.rangeValue];
  }
  /* punktuation */
  NSArray <NSValue *> *punctiationRanges = [self rangesOfCharactersInSet:NSCharacterSet.punctuationCharacterSet];
  for(NSValue *rangeValue in punctiationRanges) {
    [string addAttribute:NSForegroundColorAttributeName value:NSColor.greenColor range:rangeValue.rangeValue];
  }
}

- (NSArray<NSValue *>*)rangesOfCharactersInSet:(NSCharacterSet *)characterSet{
  NSRange searchRange = NSMakeRange(0, self.length);
  NSMutableArray <NSValue *> *ranges = [[NSMutableArray alloc] init];
  while(YES) {
    if(searchRange.location == NSNotFound) {
      break;
    }
    NSRange range = [self rangeOfCharacterFromSet:characterSet options:NSCaseInsensitiveSearch range:searchRange];
    if(range.location != NSNotFound) {
      [ranges addObject:[NSValue valueWithRange:range]];
      searchRange = NSMakeRange(range.location + range.length, self.length - range.location - range.length);
    }
    else {
      searchRange.location = NSNotFound;
    }
  }
  return [ranges copy];
}


@end
