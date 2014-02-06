//
//  MPAutotypeCommand.h
//  MacPass
//
//  Created by Michael Starke on 10/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kMPAutotypeSymbolShift;
extern NSString *const kMPAutotypeSymbolControl;
extern NSString *const kMPAutotypeSymbolAlt;
extern NSString *const kMPAutotypeSymbolEnter;
extern NSString *const kMPAutptypeCommandEnter;

extern uint16_t const kMPUnknownKeyCode;

@class MPAutotypeContext;

/**
 *  The Autotype command reperesent a capsualted Action that was determined by interpreting
 *  Autotype field for a given entry. This is a class cluster and schould be considered the sole
 *  enty point for creating AutotypeCommands.
 */
@interface MPAutotypeCommand : NSObject

@property (readonly, strong) MPAutotypeContext *context;
/**
 *  Retrieves the string representation with the current keyboard mapping for the keycode
 *
 *  @param keyCode The virutal keycode to be pressed
 *  @return NSString containing the current mapping for the keyCode
 */
+ (NSString *)stringForKey:(CGKeyCode)keyCode;

/**
 *  Determines the keyCode (if possible) for the charater
 *
 *  @param character NSString with a single character to be transformed
 *  @return virtual Keycode for the supplied string. If none is found, kMPUnkonwKeyCode is returned
 */
+ (CGKeyCode)keyCodeForCharacter:(NSString *)character;

- (id)initWithContext:(MPAutotypeContext *)context;
/**
 *  Sends a KeyPress Event with the supplied modifier flags and Keycode
 *  Any existing modifiers will be disabled for this event. If the user
 *  presses any key, those will be ignored during this event
 *
 *  @param keyCode virtual KeyCode to be sent
 *  @param flags   modifier flags for the key press event
 */
- (void)sendPressKey:(CGKeyCode)keyCode modifierFlags:(CGEventFlags)flags;

/**
 *  Convenience message to be sent for executing a simple paste command
 */
- (void)sendPasteKeyCode;

/**
 *  Exectues the Autotype Command. This will be called by the autotype daemon.
 */
- (void)execute;

@end
