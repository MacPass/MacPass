//
//  MPAutotypeCommand.h
//  MacPass
//
//  Created by Michael Starke on 10/11/13.
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
#import "MPModifiedKey.h"
@class MPAutotypeContext;

/**
 *  The Autotype command represents a capsuled Action that was determined by interpreting
 *  Autotype field for a given entry. This is a class cluster and should be considered the sole
 *  entry point for creating AutotypeCommands. You should never need to build a command on your own.
 */
@interface MPAutotypeCommand : NSObject

@property (readonly, strong) MPAutotypeContext *context;

/**
 *  Creates a command sequence for the given context. The context's keystroke sequence is
 *  is evaluated (Placeholders filled, references resolved) and the commands are created in the 
 *  order of their execution
 *
 *  @param context the context to create the commands from.
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
- (void)sendPressKey:(MPModifiedKey)key;

/**
 *  Convenience message to be sent for executing a simple paste command
 */
- (void)sendPasteKeyCode;

/**
 *  Executes the Autotype Command.
 */
- (void)execute;

/**
 *  Validates the command and returns the result
 *
 *  @return YES if the command is valid and can be executed. NO otherwise
 */
- (BOOL)isValid;

@end
