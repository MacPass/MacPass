//
//  NSString+MPPasswordCreation.h
//  MacPass
//
//  Created by Michael Starke on 29.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, MPPasswordCharacterFlags) {
  MPPasswordCharactersUpperCase = (1<<0),
  MPPasswordCharactersLowerCase = (1<<1),
  MPPasswordCharactersNumbers   = (1<<2),
  MPPasswordCharactersSymbols   = (1<<3),
  MPPasswordCharactersAll = MPPasswordCharactersUpperCase | MPPasswordCharactersLowerCase | MPPasswordCharactersNumbers | MPPasswordCharactersSymbols
};

@interface NSString (MPPasswordCreation)

/**
*  Creates a Password using the supplied password character set with the given lenght
*
*  @param allowedCharacters Characters allowed for the password
*  @param theLength         lenght of the password to be created
*
*  @return new password with only the allowed characters.
*/
+ (NSString *)passwordWithCharactersets:(MPPasswordCharacterFlags)allowedCharacters length:(NSUInteger)theLength;
/**
 *  Creats a password based on the supplied string
 *
 *  @param source String containing the allowed characters
 *  @param length Lenght for the password to be chreated
 *
 *  @return Password consisint only of allowed characters
 */
+ (NSString *)passwordFromString:(NSString *)source length:(NSUInteger)length;
/**
 *
 *  Creates a random password with only the characters of the receiver
 *
 *  @param length Length of the password to be created
 *
 *  @return Password containing only the charactesr in receiver
 */
- (NSString *)passwordWithLength:(NSUInteger)length;
/**
 *  @return returns a random character from the string
 */
- (NSString *)randomCharacter;
/**
 *  Calculates the entropy of the receiver based on the allowed characers. The caluclation consideres the characters chosen randomly.
 *  If the password supplied was not created randomly based on the full character set, the calulated entropy is NOT correct.
 *  Do NOT use this method to estrimate unknown passwords
 *
 *  @param allowedCharacters set of allowed Characters
 *  @param customCharacters  alternative string of unique allowed charactes (String is not stripped of duplicates!)
 *
 *  @return entropy of the receiver as bits
 */
- (CGFloat)entropyWhithPossibleCharacterSet:(MPPasswordCharacterFlags)allowedCharacters orCustomCharacters:(NSString *)customCharacters;

@end
