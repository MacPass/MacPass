//
//  MPPickcharParser.h
//  MacPass
//
//  Created by Michael Starke on 29.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPPickcharsParser : NSObject

@property (readonly) BOOL hideCharacters;
@property (readonly) BOOL convertToDownArrows;
@property (readonly) NSUInteger pickCount; // count to pick - 0 if unlimted
@property (readonly) NSUInteger checkboxOffset;
@property (readonly, copy) NSString *checkboxFormat;


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
