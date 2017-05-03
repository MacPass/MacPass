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
*  Creates a Password using the supplied password character set with the given length
*
*  @param allowedCharacters Characters allowed for the password
*  @param theLength         length of the password to be created
*
*  @return new password with only the allowed characters.
*/
+ (NSString *)passwordWithCharactersets:(MPPasswordCharacterFlags)allowedCharacters
                   withCustomCharacters:(NSString*)customCharacters
                                 length:(NSUInteger)theLength;
/**
 *  Creats a password based on the supplied string
 *
 *  @param source String containing the allowed characters
 *  @param length Length for the password to be created
 *
 *  @return Password consistent only of allowed characters
 */
+ (NSString *)passwordFromString:(NSString *)source length:(NSUInteger)length;

+ (NSString *)passwordWithDefaultSettings;

/**
 *  @return returns a random character from the string
 */
@property (nonatomic, readonly, copy) NSString *randomCharacter;

/**
 *
 *  Creates a random password with only the characters of the receiver
 *
 *  @param length Length of the password to be created
 *
 *  @return Password containing only the characters in receiver
 */
- (NSString *)passwordWithLength:(NSUInteger)length;
/**
 *  Calculates the entropy of the receiver based on the allowed characters. The calculation considers the characters chosen randomly.
 *  If the password supplied was not created randomly based on the full character set, the calculated entropy is NOT correct.
 *  Do NOT use this method to estimate unknown passwords
 *
 *  @param allowedCharacters set of allowed Characters
 *  @param customCharacters  alternative string of unique allowed characters (String is not stripped of duplicates!)
 *
 *  @return entropy of the receiver as bits
 */
- (CGFloat)entropyWhithPossibleCharacterSet:(MPPasswordCharacterFlags)allowedCharacters orCustomCharacters:(NSString *)customCharacters;

@end
