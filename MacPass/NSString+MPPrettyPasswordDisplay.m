//
//  NSString+MPPrettyPasswordDisplay.m
//  MacPass
//
//  Created by Michael Starke on 30.11.17.
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

#import "NSString+MPPrettyPasswordDisplay.h"
#import "KeePassKit/KeePassKit.h"

@implementation NSString (MPPrettyPasswordDisplay)

@dynamic passwordPrettified;

- (NSAttributedString *)passwordPrettified {
  NSMutableAttributedString *attributedPassword = [[NSMutableAttributedString alloc] initWithString:self];
  [self _setAttributesInString:attributedPassword];
  return [attributedPassword copy];
}

- (void)_setAttributesInString:(NSMutableAttributedString *)string {
  static NSColor *blueColor;
  static NSColor *orangeColor;
  static NSColor *greenColor;
  static NSColor *yellowColor;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    blueColor = [NSColor colorWithRed:0.3 green:0.7 blue:1 alpha:1];
    orangeColor = [NSColor colorWithRed:0.3 green:0.7 blue:1 alpha:1];
    greenColor = [NSColor colorWithRed:0.3 green:0.7 blue:1 alpha:1];
    yellowColor = [NSColor colorWithRed:0.3 green:0.7 blue:1 alpha:1];
  });
  
  /* digits */
  NSArray <NSValue *> *digitRanges = [self rangesOfCharactersInSet:NSCharacterSet.decimalDigitCharacterSet];
  for(NSValue *rangeValue in digitRanges) {
    [string addAttribute:NSForegroundColorAttributeName value:blueColor range:rangeValue.rangeValue];
  }
  /* symbols */
  NSArray <NSValue *> *symbolRanges = [self rangesOfCharactersInSet:NSCharacterSet.symbolCharacterSet];
  for(NSValue *rangeValue in symbolRanges) {
    [string addAttribute:NSForegroundColorAttributeName value:greenColor range:rangeValue.rangeValue];
  }
  /* punktuation */
  NSArray <NSValue *> *punctiationRanges = [self rangesOfCharactersInSet:NSCharacterSet.punctuationCharacterSet];
  for(NSValue *rangeValue in punctiationRanges) {
    [string addAttribute:NSForegroundColorAttributeName value:orangeColor range:rangeValue.rangeValue];
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
