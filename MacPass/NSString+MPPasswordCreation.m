//
//  NSString+MPPasswordCreation.m
//  MacPass
//
//  Created by Michael Starke on 29.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "NSString+MPPasswordCreation.h"
#import "KeePassKit/KeePassKit.h"

#import "MPSettingsHelper.h"

NSString *const kMPLowercaseLetterCharacters = @"abcdefghijklmnopqrstuvwxyz";
NSString *const kMPNumberCharacters = @"1234567890";
NSString *const kMPSymbolCharacters = @"!$%&\\|/<>(){}[]=?*'+#-_.:,;";

static NSString *allowedCharactersString(MPPasswordCharacterFlags flags) {
  NSMutableString *characterString = [NSMutableString stringWithCapacity:30];
  if(flags & MPPasswordCharactersLowerCase) {
    [characterString appendString:kMPLowercaseLetterCharacters];
  }
  if(flags & MPPasswordCharactersUpperCase) {
    [characterString appendString:[kMPLowercaseLetterCharacters uppercaseString]];
  }
  if(flags & MPPasswordCharactersNumbers) {
    [characterString appendString:kMPNumberCharacters];
  }
  if(flags & MPPasswordCharactersSymbols){
    [characterString appendString:kMPSymbolCharacters];
  }
  return characterString;
}

static NSString *mergeWithoutDuplicates(NSString* baseCharacters, NSString* customCharacters){
  NSInteger maxLength = baseCharacters.length + customCharacters.length;
  NSMutableString* mergedCharacters = [NSMutableString stringWithCapacity: maxLength];
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
  while(password.length < length) {
    [password appendString:[source randomCharacter]];
  }
  return password;
}

+ (NSString *)passwordWithCharactersets:(MPPasswordCharacterFlags)allowedCharacters
                   withCustomCharacters:(NSString*)customCharacters
                                 length:(NSUInteger)length {
  NSMutableString *password = [NSMutableString stringWithCapacity:length];
  NSString *characters = mergeWithoutDuplicates(
                                                allowedCharactersString(allowedCharacters),
                                                customCharacters);
  while(password.length < length) {
    NSString *randomCharacter = [characters randomCharacter];
    if(randomCharacter.length > 0) {
      [password appendString:randomCharacter];
    }
    else {
      break;
    }
  }
  return password;
}

+ (NSString *)passwordWithDefaultSettings {
  /* generate and pre-fill password using default password creation settings */
  NSUInteger passwordLength = [[NSUserDefaults standardUserDefaults] integerForKey:kMPSettingsKeyDefaultPasswordLength];
  MPPasswordCharacterFlags characterFlags = [[NSUserDefaults standardUserDefaults] integerForKey:kMPSettingsKeyPasswordCharacterFlags];
  BOOL useCustomString = [[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyPasswordUseCustomString];
  NSString *customString = [[NSUserDefaults standardUserDefaults] stringForKey:kMPSettingsKeyPasswordCustomString];
  
  if(useCustomString && customString.length > 0) {
    return [customString passwordWithLength:passwordLength];
  }
  return [NSString passwordWithCharactersets:characterFlags
                        withCustomCharacters:@""
                                      length:passwordLength];
}

- (NSString *)passwordWithLength:(NSUInteger)length {
  return [NSString passwordFromString:self length:length];
}

- (NSString *)randomCharacter {
  if([self length] == 0) {
    return nil;
  }
  NSData *data = [NSData kpk_dataWithRandomBytes:sizeof(NSUInteger)];
  NSUInteger randomIndex;
  [data getBytes:&randomIndex length:data.length];
  return [self substringWithRange:NSMakeRange(randomIndex % self.length, 1)];
}

- (CGFloat)entropyWhithPossibleCharacterSet:(MPPasswordCharacterFlags)allowedCharacters orCustomCharacters:(NSString *)customCharacters {
  NSString *characters = nil;
  if([[NSUserDefaults standardUserDefaults] boolForKey:kMPSettingsKeyPasswordUseCustomString] && nil != customCharacters) {
    characters = mergeWithoutDuplicates(
                                        allowedCharactersString(allowedCharacters),
                                        customCharacters);
  }
  else {
    characters = allowedCharactersString(allowedCharacters);
  }
  CGFloat alphabetCount = characters.length;
  CGFloat passwordLength = self.length;
  return passwordLength * ( log10(alphabetCount) / log10(2) );
}
@end
