//
//  MPAutotypeCommand.h
//  MacPass
//
//  Created by Michael Starke on 10/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPAutotypeContext;

/**
 *  The Autotype command reperesent a capsualted Action that was determined by interpreting
 *  Autotype field for a given entry. This is a class cluster and schould be considered the sole
 *  enty point for creating AutotypeCommands. You should never need to build a command on your own.
 */
@interface MPAutotypeCommand : NSObject

@property (readonly, strong) MPAutotypeContext *context;

/**
 *  Creates a command sequence for the given context. The context's keystroke sequence is
 *  is evaluated (Placholders filled, references resolved) and the commands are created in the 
 *  order of their execution
 *
 *  @param context the context to create the comamnds from.
 *
 *  @return NSArray of MPAutotypeCommand
 */
+ (NSArray *)commandsForContext:(MPAutotypeContext *)context;

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
 *  Exectues the Autotype Command.
 */
- (void)execute;

/**
 *  Validates the command and returns the result
 *
 *  @return YES if the command is valid and can be executed. NO otherwise
 */
- (BOOL)isValid;

@end
