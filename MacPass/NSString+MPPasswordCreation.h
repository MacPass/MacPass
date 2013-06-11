//
//  NSString+MPPasswordCreation.h
//  MacPass
//
//  Created by Michael Starke on 29.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  MPPasswordCharactersUpperCase = (1<<0), // NSCharacterset lowerCaseCharacterSet
  MPPasswordCharactersLowerCase = (1<<1), // NSCharacterSet upperCaseCharacterSet
  MPPasswordCharactersNumbers   = (1<<2), // NSCharacterSet numberCharacterSet
  MPPasswordCharactersSymbols   = (1<<3),   // NSCharacterSet symbolCharacterSet
  MPPasswordCharactersAll = MPPasswordCharactersUpperCase | MPPasswordCharactersLowerCase | MPPasswordCharactersNumbers | MPPasswordCharactersSymbols
} MPPasswordCharacterFlags;

/*
 Generates a random integer in between (inkluding) minimum and maxium
 */
static NSUInteger randomInteger(NSUInteger minimum, NSUInteger maximum);

@interface NSString (MPPasswordCreation)

/*
 Generates a new password with the allowed charaters an the requests lenght
 @param array with allowed NSChractersSets for creation
 @param lenght lenght of the password to create
 */
+ (NSString *)passwordWithCharactersets:(MPPasswordCharacterFlags)allowedCharacters length:(NSUInteger)theLength;
/*
 Generates a new password with the given length and allowed characters
 @param Source string of allowed characters
 @param lenght Lenght of the password to create
 @return Password
 */
+ (NSString *)passwordFromString:(NSString *)source length:(NSUInteger)length;

/*
 Creates a password containing only the characters in the string
 @param Lenght of the password
 */
- (NSString *)passwordWithLength:(NSUInteger)length;

/*
 Returns a random Character from the String
 */
- (NSString *)randomCharacter;

@end
