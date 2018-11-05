//
//  MPAutotypeCommand.m
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

#import "MPAutotypeCommand.h"
#import "MPAutotypeParser.h"
#import "MPAutotypeContext.h"

@implementation MPAutotypeCommand

+ (NSArray *)commandsForContext:(MPAutotypeContext *)context {
  if(!context.valid) {
    return @[];
  }
  MPAutotypeParser *parser = [[MPAutotypeParser alloc] initWithContext:context];
  return parser.commands;
}

- (void)execute {
  NSAssert(NO, @"Not Implemented");
}

- (BOOL)isValid {
  return NO; // No valid command
}

@end
