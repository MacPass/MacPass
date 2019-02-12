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
