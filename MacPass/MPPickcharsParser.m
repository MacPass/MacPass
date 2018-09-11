//
//  MPPickcharParser.m
//  MacPass
//
//  Created by Michael Starke on 29.11.17.
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

#import "MPPickcharsParser.h"
#import "MPPickcharsParser_Private.h"

#import "NSString+MPComposedCharacterAdditions.h"

#import <KeePassKit/KeePassKit.h>

typedef NS_ENUM(NSInteger, MPPickCharOffsetType) {
  MPPickCharOffsetTypeNone,
  MPPickCharOffsetTypeLowerCaseCharacter,
  MPPickCharOffsetTypeUpperCaseCharacter,
  MPPickCharOffsetTypeNumber,
};

struct MPPickCharOffset {
  MPPickCharOffsetType type;
  NSUInteger offset;
};
typedef struct MPPickCharOffset MPPickCharOffset;

MPPickCharOffset MPMakePickCharUpperCaseCharacterOffset(unichar c) {
  MPPickCharOffset offsetStruct = {MPPickCharOffsetTypeUpperCaseCharacter, c - 'A'};
  return offsetStruct;
}

MPPickCharOffset MPMakePickCharLowerCaseCharacterOffset(unichar c) {
  MPPickCharOffset offsetStruct = {MPPickCharOffsetTypeLowerCaseCharacter, c - 'a'};
  return offsetStruct;
}

MPPickCharOffset MPMakePickCharNumberOffset(unichar c) {
  MPPickCharOffset offsetStruct = {MPPickCharOffsetTypeNumber, c - '0'};
  return offsetStruct;
}

MPPickCharOffset MPMakeInvalidPickCharOffset(void) {
  MPPickCharOffset offset = {MPPickCharOffsetTypeNone,0};
  return offset;
}

MPPickCharOffset MPMakePickCharOffset(unichar character) {
  if(character >= '0' && character <= '9') {
    return MPMakePickCharNumberOffset(character);
  }
  else if(character >= 'a' && character <= 'z') {
    return MPMakePickCharLowerCaseCharacterOffset(character);
  }
  else if(character >= 'A' && character <= 'Z') {
    return MPMakePickCharUpperCaseCharacterOffset(character);
  }
  return MPMakeInvalidPickCharOffset();
}

BOOL MPIsValidPickCharOffset(MPPickCharOffset offset) {
  return (offset.type != MPPickCharOffsetTypeNone);
}

NSInteger numberOffset(MPPickCharOffset offset) {
  return (offset.type == MPPickCharOffsetTypeNumber ? offset.offset : 0);
}

NSInteger characterOffset(MPPickCharOffset offset) {
  switch(offset.type) {
    case MPPickCharOffsetTypeUpperCaseCharacter:
    case MPPickCharOffsetTypeLowerCaseCharacter:
      return offset.offset;
    default:
      return 0;
  }
}

typedef NSUInteger (^MPPickcharOffsetConverter)(NSInteger offset);

@interface MPPickcharsParser () {
  NSDictionary <NSValue *, MPPickcharOffsetConverter> *_offsetConverter;
}
@end

@implementation MPPickcharsParser

- (instancetype)init {
  self = [self initWithOptions:nil];
  return self;
}

- (instancetype)initWithOptions:(NSString *)options {
  self = [super init];
  if(self) {
    _pickCount = 0;
    _checkboxOffset = 0;
    _convertToDownArrows = NO;
    _hideCharacters = YES;
    _offsetConverter = nil;
    [self _parseOptions:options];
  }
  return self;
}

- (NSString *)processPickedString:(NSString *)string {
  if(!self.convertToDownArrows) {
    return string;
  }
  NSMutableString *mutableString = [[NSMutableString alloc] init];
  for(NSString *substring in string.composedCharacters) {
    if(substring.length != 1) {
      NSLog(@"Pickchars: Unsupported character %@ for conversion to down arrows, skipping!", substring);
      continue;
    }
    unichar character = [substring characterAtIndex:0];
    MPPickCharOffset offset = MPMakePickCharOffset(character);
    [self _appendKeyCommandsForOffset:offset toString:mutableString];
  }
  return [mutableString copy];
}

- (void)_appendKeyCommandsForOffset:(MPPickCharOffset)offset toString:(NSMutableString *)string {
  if(!MPIsValidPickCharOffset(offset)) {
    return;
  }
  NSUInteger actualOffset = self.checkboxOffset;
  MPPickcharOffsetConverter convertBlock = _offsetConverter[@(offset.type)];
  if(convertBlock) {
    actualOffset += convertBlock(offset.offset);
  }
  else {
    actualOffset += offset.offset;
  }
  while (actualOffset--) {
    [string appendString:kKPKAutotypeDown];
  }
}
/*
 {PICKCHAR:Field:Options}
 
 Options allow to convert picked character to be typed into drop-down-boxes.
 E.g. select digits or letters
 Options:
 
 ID=id (id for multiple pickchars in a field will not get processed
 Conv=D If set, convert values to down arrow presses
 Conv-Offset= Offset for conversion of characters, will be added to all arrow presses
 
 Conv-Fmt= Format of the check-box
 
 0 - Numbers 0129456789
 1 - Number 1234567890
 a - lowercase characters
 A - uppercase characters
 ? - skip combobox item
 
 -> combine for layout e.g. 0a or 0aA 0?aA
 */
- (void)_parseOptions:(NSString *)options {
  for(NSString *option in [options componentsSeparatedByString:kKPKPlaceholderPickCharsOptionDelemiter]) {
    NSArray <NSString *>*keyValuePair = [option componentsSeparatedByString:@"="];
    if(![self _parseOptionKeyValuePair:keyValuePair]) {
      NSLog(@"Invalid Option: %@", option);
      continue;
    };
  }
}

- (BOOL)_parseOptionKeyValuePair:(NSArray <NSString *> *)optionPair {
  if(optionPair.count != 2) {
    return NO;
  }
  NSString *key = [optionPair.firstObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
  NSString *option = [optionPair.lastObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
  
  /* Character count option */
  if(NSOrderedSame == [key compare:kKPKPlaceholderPickCharsOptionCount options:NSCaseInsensitiveSearch]
     || NSOrderedSame == [key compare:kKPKPlaceholderPickCharsOptionCountShort options:NSCaseInsensitiveSearch]) {
    NSScanner *scanner = [[NSScanner alloc] initWithString:option];
    NSInteger count;
    if([scanner scanInteger:&count]) {
      if(count != INT_MIN && count != INT_MAX) {
        self.pickCount = MAX(0,count);
        return YES;
      }
    }
    return NO;
  }
  /* Hide characters option */
  if(NSOrderedSame == [key compare:kKPKPlaceholderPickCharsOptionHide options:NSCaseInsensitiveSearch]) {
    if(NSOrderedSame == [option compare:@"false" options:NSCaseInsensitiveSearch]) {
      self.hideCharacters = NO;
      return YES;
    }
    if(NSOrderedSame == [option compare:@"true" options:NSCaseInsensitiveSearch]) {
      self.hideCharacters = YES;
      return YES;
    }
    return NO;
  }
  /* Convert to down arrows option */
  if(NSOrderedSame == [key compare:kKPKPlaceholderPickCharsOptionConvert options:NSCaseInsensitiveSearch]) {
    if(NSOrderedSame == [option compare:@"D" options:NSCaseInsensitiveSearch]) {
      self.convertToDownArrows = YES;
      return YES;
    }
    return NO;
  }
  /* Offset option for down arrow conversion */
  if(NSOrderedSame == [key compare:kKPKPlaceholderPickCharsOptionConvertOffset options:NSCaseInsensitiveSearch]) {
    NSScanner *scanner = [[NSScanner alloc] initWithString:option];
    NSInteger offset;
    if([scanner scanInteger:&offset]) {
      if(offset != INT_MIN && offset != INT_MAX) {
        self.checkboxOffset = MAX(0,offset);
        return YES;
      }
    }
    return NO;
  }
  /* Special checkbox format option */
  if(NSOrderedSame == [key compare:kKPKPlaceholderPickCharsOptionConvertFormat options:NSCaseInsensitiveSearch]) {
    if(option.length == 0) {
      /* interpret no optoins as default too*/
      return YES;
    }
    /* parse range format */
    NSMutableDictionary *tmpOffsetMap = [[NSMutableDictionary alloc] init];
    NSUInteger index = 0;
    NSUInteger collectedOffset = 0;
    while(index < option.length) {
      NSString *formatOption = [option substringWithRange:NSMakeRange(index, 1)];
      if([formatOption isEqualToString:@"0"]) {
        if(tmpOffsetMap[@(MPPickCharOffsetTypeNumber)]) {
          return NO; // double definition!
        }
        tmpOffsetMap[@(MPPickCharOffsetTypeNumber)] = ^NSInteger(NSUInteger offset) {
          return offset + collectedOffset;
        };
        collectedOffset += 10;
      }
      else if([formatOption isEqualToString:@"1"]) {
        if(tmpOffsetMap[@(MPPickCharOffsetTypeNumber)]) {
          return NO; // double definition!
        }
        tmpOffsetMap[@(MPPickCharOffsetTypeNumber)] = ^NSInteger(NSUInteger offset) {
          NSInteger tmpOffset = offset - 1;
          if(tmpOffset < 0) {
            tmpOffset += 10;
          }
          return tmpOffset + collectedOffset;
        };
        collectedOffset += 10;
      }
      else if([formatOption isEqualToString:@"a"]) {
        if(tmpOffsetMap[@(MPPickCharOffsetTypeLowerCaseCharacter)]) {
          return NO; // double definition!
        }

        tmpOffsetMap[@(MPPickCharOffsetTypeLowerCaseCharacter)] = ^NSInteger(NSUInteger offset) {
          return offset + collectedOffset;
        };
        collectedOffset += 26;
      }
      else if([formatOption isEqualToString:@"A"]) {
        if(tmpOffsetMap[@(MPPickCharOffsetTypeUpperCaseCharacter)]) {
          return NO; // double definition!
        }
        
        tmpOffsetMap[@(MPPickCharOffsetTypeUpperCaseCharacter)] = ^NSInteger(NSUInteger offset) {
          return offset + collectedOffset;
        };
        collectedOffset += 26;
      }
      else if([formatOption isEqualToString:@"?"]) {
        /* just collect skips */
        collectedOffset++;
      }
      else {
        return NO;
      }
      index++;
    }
    NSAssert(tmpOffsetMap.count > 0, @"Internal inconsistency. Offset format needs at least on valid format!");
    /* default behaviour is to be case insensitive, make sure we use the same converter for both cases if only one is specifier */
    MPPickcharOffsetConverter upperCaseConverter = tmpOffsetMap[@(MPPickCharOffsetTypeUpperCaseCharacter)];
    MPPickcharOffsetConverter lowerCaseConverter = tmpOffsetMap[@(MPPickCharOffsetTypeLowerCaseCharacter)];
    if(upperCaseConverter && !lowerCaseConverter) {
      tmpOffsetMap[@(MPPickCharOffsetTypeLowerCaseCharacter)] = upperCaseConverter;
    }
    else if(!upperCaseConverter && lowerCaseConverter) {
      tmpOffsetMap[@(MPPickCharOffsetTypeUpperCaseCharacter)] = lowerCaseConverter;
    }

    _offsetConverter = [tmpOffsetMap copy];
    return YES;
  }
  return NO;
}

@end
