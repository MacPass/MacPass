//
//  NSString+MPPasswordCreation.h
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
                            ensureOccurence:(BOOL)ensureOccurence
                                 length:(NSUInteger)length;
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

+ (NSUInteger)minimumPasswordLengthWithCharacterSet:(MPPasswordCharacterFlags)characterSet customCharacters:(NSString *)customCharacter ensureOccurance:(BOOL)ensureOccurance;
/**
 *  @return returns a random character from the string
 */
@property (nonatomic, readonly, copy) NSString *randomCharacter;
/**
 * @return returns a shuffled copy of the receiving string
 */
@property (nonatomic, readonly, copy) NSString *shuffledString;

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
 *  Do NOT use this method to estimate passwords with unknown alphabet
 *
 *  @param allowedCharacters set of allowed Characters
 *  @param customCharacters  additional custom string of allowed characters.
 *
 *  @return entropy of the receiver as bits
 */
- (CGFloat)entropyWhithCharacterSet:(MPPasswordCharacterFlags)characterSet customCharacters:(NSString *)customCharacters ensureOccurance:(BOOL)ensureOccurance;

@end
