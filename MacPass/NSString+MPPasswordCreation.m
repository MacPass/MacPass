//
//  NSString+MPPasswordCreation.m
//  MacPass
//
//  Created by Michael Starke on 29.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "NSString+MPPasswordCreation.h"
#import "NSData+MPRandomBytes.h"

NSString *const kMPLowercaseLetterCharacters = @"abcdefghijklmnopqrstuvw";
NSString *const kMPNumberCharacters = @"1234567890";
NSString *const kMPSymbolCharacters = @"!$%&\\|/<>(){}[]=?*'+#-_.:,;";


static NSUInteger randomInteger(NSUInteger minimum, NSUInteger maximum) {
  NSInteger delta = maximum - minimum;
  if( delta == 0) {
    return maximum;
  }
  if( delta < 0 ) {
    minimum -= delta;
    delta = -delta;
  }
  NSUInteger randomByteSize = floor(log2(delta));
  NSData *randomData = [NSData dataWithRandomBytes:randomByteSize];
  NSNumber *number = [NSNumber numberWithUnsignedChar:(unsigned char)[randomData bytes]];
  NSUInteger randomNumber = [number integerValue];
  return minimum + (randomNumber % delta);
}

static NSString *allowedCharactersString(MPPasswordCharacterFlags flags) {
  NSMutableString *characterString = [NSMutableString stringWithCapacity:30];
  if( 0 != (flags & MPPasswordCharactersLowerCase) ) {
    [characterString appendString:kMPLowercaseLetterCharacters];
  }
  if( 0 != (flags & MPPasswordCharactersUpperCase) ) {
    [characterString appendString:[kMPLowercaseLetterCharacters uppercaseString]];
  }
  if(0 != (flags & MPPasswordCharactersNumbers) ) {
    [characterString appendString:kMPNumberCharacters];
  }
  if(0 != (flags & MPPasswordCharactersSymbols) ){
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
  NSUInteger randomIndex = randomInteger(0, [self length] - 1);
  if(randomIndex >= [self length]) {
    return nil;
  }
  return [self substringWithRange:NSMakeRange(randomIndex, 1)];
}

@end
