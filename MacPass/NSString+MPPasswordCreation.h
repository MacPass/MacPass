//
//  NSString+MPPasswordCreation.h
//  MacPass
//
//  Created by Michael Starke on 29.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, MPPasswordCharacterFlags) {
  MPPasswordCharactersUpperCase = (1<<0), // NSCharacterset lowerCaseCharacterSet
  MPPasswordCharactersLowerCase = (1<<1), // NSCharacterSet upperCaseCharacterSet
  MPPasswordCharactersNumbers   = (1<<2), // NSCharacterSet numberCharacterSet
  MPPasswordCharactersSymbols   = (1<<3),   // NSCharacterSet symbolCharacterSet
  MPPasswordCharactersAll = MPPasswordCharactersUpperCase | MPPasswordCharactersLowerCase | MPPasswordCharactersNumbers | MPPasswordCharactersSymbols
};

@interface NSString (MPPasswordCreation)

/**
 @param array with allowed NSChractersSets for creation
 @param lenght lenght of the password to create
 @returns a new password with the allowed charaters an the requests lenght
 */
+ (NSString *)passwordWithCharactersets:(MPPasswordCharacterFlags)allowedCharacters length:(NSUInteger)theLength;
/**
 @param Source string of allowed characters
 @param lenght Lenght of the password to create
 @return a new password with the given length and allowed characters
 */
+ (NSString *)passwordFromString:(NSString *)source length:(NSUInteger)length;

/**
 @param Length of the password
 @returns a password containing only the characters in the string
 */
- (NSString *)passwordWithLength:(NSUInteger)length;

/**
 @returns a random Character from the String
 */
- (NSString *)randomCharacter;
/**
 @param allowedCharacters Characters that where allowed for the cration of the password
 @returns entrpy in bits taking into account, the creation was purely random. Do not use this to estimate user generated passswords
 */
- (CGFloat)entropyWhithPossibleCharacterSet:(MPPasswordCharacterFlags)allowedCharacters orCustomCharacters:(NSString *)customCharacters;

@end
