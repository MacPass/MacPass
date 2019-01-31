//
//  NSString+MPPasswordCreation.m
//  MacPass
//
//  Created by Michael Starke on 29.03.13.
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

#import "NSString+MPPasswordCreation.h"
#import "KeePassKit/KeePassKit.h"

#import "NSString+MPComposedCharacterAdditions.h"
#import "MPSettingsHelper.h"

static NSDictionary<NSNumber *, NSString *> *characterClassMap () {
  static dispatch_once_t onceToken;
  static NSDictionary *characterClassMap;
  dispatch_once(&onceToken, ^{
    characterClassMap = @{ @(MPPasswordCharactersLowerCase) : @"abcdefghijklmnopqrstuvwxyz",
                           @(MPPasswordCharactersUpperCase) : @"abcdefghijklmnopqrstuvwxyz".uppercaseString,
                           @(MPPasswordCharactersNumbers) : @"1234567890",
                           @(MPPasswordCharactersSymbols) : @"!$%&\\|/<>(){}[]=?*'+#-_.:,;"
                           };
  });
  return characterClassMap;
}

static NSString *allowedCharactersString(MPPasswordCharacterFlags flags) {
  NSMutableString *characterString = [NSMutableString stringWithCapacity:30];
  if(flags & MPPasswordCharactersLowerCase) {
    [characterString appendString:characterClassMap()[@(MPPasswordCharactersLowerCase)]];
  }
  if(flags & MPPasswordCharactersUpperCase) {
    [characterString appendString:characterClassMap()[@(MPPasswordCharactersUpperCase)]];
  }
  if(flags & MPPasswordCharactersNumbers) {
    [characterString appendString:characterClassMap()[@(MPPasswordCharactersNumbers)]];
  }
  if(flags & MPPasswordCharactersSymbols){
    [characterString appendString:characterClassMap()[@(MPPasswordCharactersSymbols)]];
  }
  return characterString;
}

static NSString *mergeWithoutDuplicates(NSString* baseCharacters, NSString* customCharacters){
  NSMutableString* mergedCharacters = [[NSMutableString alloc] init];
  [mergedCharacters appendString:baseCharacters];
  [customCharacters enumerateSubstringsInRange: NSMakeRange(0, customCharacters.length)
                                       options: NSStringEnumerationByComposedCharacterSequences
                                    usingBlock: ^(NSString *inSubstring, NSRange inSubstringRange, NSRange inEnclosingRange, BOOL *outStop) {
                                      if(0 == [mergedCharacters rangeOfString:inSubstring].length){
                                        [mergedCharacters appendString:inSubstring];
                                      }
                                    }];
  return [NSString stringWithString:mergedCharacters];
}

@implementation NSString (MPPasswordCreation)

+ (NSString *)passwordFromString:(NSString *)source length:(NSUInteger)length {
  NSMutableString *password = [[NSMutableString alloc] initWithCapacity:length];
  while(password.composedCharacterLength < length) {
    [password appendString:source.randomCharacter];
  }
  return password;
}

+ (NSString *)passwordWithCharactersets:(MPPasswordCharacterFlags)allowedCharacters
                   withCustomCharacters:(NSString *)customCharacters
                        ensureOccurence:(BOOL)ensureOccurence
                                 length:(NSUInteger)length {
  if(ensureOccurence) {
    length = MAX(length, [NSString minimumPasswordLengthWithCharacterSet:allowedCharacters customCharacters:customCharacters ensureOccurance:ensureOccurence]);
  }
  NSMutableString *password = [NSMutableString stringWithCapacity:length];
  NSString *characters = mergeWithoutDuplicates(
                                                allowedCharactersString(allowedCharacters),
                                                customCharacters);
  if(ensureOccurence) {
    if(allowedCharacters & MPPasswordCharactersLowerCase) {
      [password appendString:characterClassMap()[@(MPPasswordCharactersLowerCase)].randomCharacter];
    }
    if(allowedCharacters & MPPasswordCharactersUpperCase) {
      [password appendString:characterClassMap()[@(MPPasswordCharactersUpperCase)].randomCharacter];
    }
    if(allowedCharacters & MPPasswordCharactersNumbers) {
      [password appendString:characterClassMap()[@(MPPasswordCharactersNumbers)].randomCharacter];
    }
    if(allowedCharacters & MPPasswordCharactersSymbols){
      [password appendString:characterClassMap()[@(MPPasswordCharactersSymbols)].randomCharacter];
    }
    if(customCharacters.length > 0) {
      [password appendString:customCharacters.randomCharacter];
    }
  }
  while(password.composedCharacterLength < length) {
    NSString *randomCharacter = characters.randomCharacter;
    if(randomCharacter.length > 0) {
      [password appendString:randomCharacter];
    }
    else {
      break;
    }
  }
  return ensureOccurence ? password.shuffledString : password;
}

+ (NSString *)passwordWithDefaultSettings {
  /* generate and pre-fill password using default password creation settings */
  NSUInteger passwordLength = [NSUserDefaults.standardUserDefaults integerForKey:kMPSettingsKeyDefaultPasswordLength];
  MPPasswordCharacterFlags characterFlags = [NSUserDefaults.standardUserDefaults integerForKey:kMPSettingsKeyPasswordCharacterFlags];
  BOOL useCustomString = [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyPasswordUseCustomString];
  NSString *customString = [NSUserDefaults.standardUserDefaults stringForKey:kMPSettingsKeyPasswordCustomString];
  
  if(useCustomString && customString.length > 0) {
    return [customString passwordWithLength:passwordLength];
  }
  return [NSString passwordWithCharactersets:characterFlags withCustomCharacters:@"" ensureOccurence:NO length:passwordLength];
}

+ (NSUInteger)minimumPasswordLengthWithCharacterSet:(MPPasswordCharacterFlags)characterSet customCharacters:(NSString *)customCharacter ensureOccurance:(BOOL)ensureOccurance {
  NSUInteger minimumPasswordLength = 0;
  NSUInteger activeFlags = characterSet;
  while(activeFlags > 0) {
    if(activeFlags & 1) {
      minimumPasswordLength++;
    }
    activeFlags >>= 1;
  }
  if(customCharacter.length > 0) {
    minimumPasswordLength++;
  }
  return minimumPasswordLength;
}

- (NSString *)passwordWithLength:(NSUInteger)length {
  return [NSString passwordFromString:self length:length];
}

- (NSString *)randomCharacter {
  if(self.length == 0) {
    return nil;
  }
  return [self composedCharacterAtIndex:arc4random_uniform((int)self.composedCharacterLength)];
}


- (CGFloat)entropyWhithCharacterSet:(MPPasswordCharacterFlags)characterSet customCharacters:(NSString *)customCharacters ensureOccurance:(BOOL)ensureOccurance {
  CGFloat passwordLength = self.composedCharacterLength;
  CGFloat entropy = 0;
  if(ensureOccurance) {
    CGLError alphabetCount = 0;
    if(characterSet & MPPasswordCharactersLowerCase) {
      alphabetCount = (CGFloat)characterClassMap()[@(MPPasswordCharactersLowerCase)].length;
      entropy += log2(alphabetCount);
    }
    if(characterSet & MPPasswordCharactersUpperCase) {
      alphabetCount = (CGFloat)characterClassMap()[@(MPPasswordCharactersUpperCase)].length;
      entropy += log2(alphabetCount);
    }
    if(characterSet & MPPasswordCharactersNumbers) {
      alphabetCount = (CGFloat)characterClassMap()[@(MPPasswordCharactersNumbers)].length;
      entropy += log2(alphabetCount);
      
    }
    if(characterSet & MPPasswordCharactersSymbols){
      alphabetCount = (CGFloat)characterClassMap()[@(MPPasswordCharactersSymbols)].length;
      entropy += log2(alphabetCount);
      
    }
    if(customCharacters.composedCharacterLength > 0) {
      entropy += log2(customCharacters.composedCharacterLength);
    }
    NSUInteger minLenght = [NSString minimumPasswordLengthWithCharacterSet:characterSet customCharacters:customCharacters ensureOccurance:ensureOccurance];
    passwordLength -= minLenght;
  }
  NSString *characters = mergeWithoutDuplicates(allowedCharactersString(characterSet), customCharacters);
  CGFloat alphabetCount = characters.composedCharacterLength;
  entropy += passwordLength * log2(alphabetCount);
  
  return entropy;
}

- (NSString *)shuffledString {
  NSMutableArray *characters = [self.composedCharacters mutableCopy];
  NSMutableString *shuffled = [[NSMutableString alloc] init];
  while(characters.count > 0) {
    NSUInteger index = arc4random_uniform((int)characters.count);
    [shuffled appendString:characters[index]];
    [characters removeObjectAtIndex:index];
  }
  return [shuffled copy];
}


@end
