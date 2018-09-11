//
//  MPPickcharParser.h
//  MacPass
//
//  Created by Michael Starke on 29.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
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

@interface MPPickcharsParser : NSObject

@property (readonly) BOOL hideCharacters;
@property (readonly) BOOL convertToDownArrows;
@property (readonly) NSUInteger pickCount; // count to pick - 0 if unlimted
@property (readonly) NSUInteger checkboxOffset;

/**
 Initializes the parser with the given option string.

 @param options Options raw as from PICKCHARS entry
 @return Parser instance configured with the provided options or defaults if errors occured
 */
- (instancetype)initWithOptions:(NSString *)options NS_DESIGNATED_INITIALIZER;

/**
 This message is used to actually process any input string picked by the user
 into the format specified by the options.
 For a default initalized parsers input will be the same as output,
 If conversion is enabled, the string will contain autotype commands for arrow presses, tabs etc.
 The returned string is to be processed further by the autotype system to yield the final values.

 @param string Input value picked by the user
 @return converted input as set by the options
 */
- (NSString *)processPickedString:(NSString *)string;

@end
