//
//  NSString+MPPasswordCreation.m
//  MacPass
//
//  Created by Michael Starke on 29.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "NSString+MPPasswordCreation.h"
#import "NSData+Random.h"

NSString *const kMPLowercaseLetterCharacters = @"abcdefghijklmnopqrstuvw";
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

@implementation NSString (MPPasswordCreationTools)

+ (NSDictionary *)_createPasswordSet:(MPPasswordCharacterFlags)flags {
  return [NSDictionary dictionary];
}

- (NSDictionary *)_createPasswordSet:(MPPasswordCharacterFlags)flags {
  return [NSString _createPasswordSet:flags];
}

@end

@implementation NSString (MPPasswordCreation)

+ (NSString *)passwordFromString:(NSString *)source length:(NSUInteger)length {
  NSMutableString *password = [[NSMutableString alloc] initWithCapacity:length];
  while([password length] < length) {
    [password appendString:[source randomCharacter]];
  }
  return [password autorelease];
}

+ (NSString *)passwordWithCharactersets:(MPPasswordCharacterFlags)allowedCharacters length:(NSUInteger)length {
  NSMutableString *password = [NSMutableString stringWithCapacity:length];
  NSString *characters = allowedCharactersString(allowedCharacters);
  while([password length] < length) {
    [password appendString:[characters randomCharacter]];
  }
  return password;
}

- (NSString *)passwordWithLength:(NSUInteger)length {
  return [NSString passwordFromString:self length:length];
}

- (NSString *)randomCharacter {
  NSData *data = [NSData dataWithRandomBytes:sizeof(unsigned long)];
  NSUInteger randomIndex;
  [data getBytes:&randomIndex length:[data length]];
  return [self substringWithRange:NSMakeRange(randomIndex % [self length], 1)];
}

@end
