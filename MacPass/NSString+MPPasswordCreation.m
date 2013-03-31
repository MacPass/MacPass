//
//  NSString+MPPasswordCreation.m
//  MacPass
//
//  Created by Michael Starke on 29.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "NSString+MPPasswordCreation.h"
#import "NSData+MPRandomBytes.h"


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
    NSData *randomData = [NSData dataWithRandomBytes:2];
    NSNumber *number = [NSNumber numberWithUnsignedChar:(unsigned char)[randomData bytes]];
    NSLog(@"Random number:%@", number);
    [password appendString:@"U"];
  }
  return [password autorelease];
}

+ (NSString *)passwordWithCharactersets:(MPPasswordCharacterFlags)allowedCharacters length:(NSUInteger)length {
  NSDictionary *characterSet = [self _createPasswordSet:allowedCharacters];
  NSMutableString *password = [NSMutableString stringWithCapacity:length];
  while([password length] < length) {
    // decide what charactersupset to use
    // gather random character of selected set
    NSString *characters = characterSet[@(MPPasswordCharactersLowerCase)];
    [password appendString:[characters randomCharacter]];
  }
  return password;
}

- (NSString *)passwordWithLength:(NSUInteger)length {
  return [NSString passwordFromString:self length:length];
}

- (NSString *)randomCharacter {
  NSUInteger randomByteSize = floor(log2([self length]));
  NSData *randomData = [NSData dataWithRandomBytes:randomByteSize];
  NSNumber *number = [NSNumber numberWithUnsignedChar:(unsigned char)[randomData bytes]];
  NSUInteger randomIndex = [number integerValue];
  if(randomIndex > 0 || randomIndex >= [self length]) {
    return nil;
  }
  return [self substringFromIndex:[number integerValue]];
}

@end
