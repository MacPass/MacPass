//
//  MPAutotypeSequence.h
//  MacPass
//
//  Created by Michael Starke on 29/11/13.
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

@class KPKEntry;
@class KPKWindowAssociation;

/**
 *  Context for a autotype command run.
 *  It stores the Entry and corresponding sequence to use for autotyping
 */
@interface MPAutotypeContext : NSObject <NSCopying>

/**
 *  The entry associated with the command sequence.
 */
@property (nonatomic, strong) KPKEntry *entry;
/**
 *  The Autotype command as it's supplied by the entry
 */
@property (nonatomic, readonly, copy) NSString *command;
@property (nonatomic, readonly, copy) NSString *normalizedCommand;
/**
 *  Command with placeholders and references resolved.
 *  This will evaluate any placeholder regardless of side-effects.
 *  If you need to evaluat the command without interaction, you should call kpk_finalValueForEntry:options: directly on the normalizedCommand.
 */
@property (nonatomic, readonly, copy) NSString *evaluatedCommand;
/**
 @return command with placeholders and references resolved but masked password placeholder.
 
 This will call kpk_finalValueForEntry:options on the normalizedCommand with options set to KPKCommandEvaluationOptionSkipUserInteraction and KPKCommandEvaluationOptionReadOnly.
 This way it is ensured that the value can be used in UI without any intereference or data changes!
 */
@property (nonatomic, readonly, copy) NSString *maskedEvaluatedCommand;
/**
 *  @return YES if valid, NO otherwise
 */
@property (nonatomic, readonly, assign) BOOL valid;

/**
 *  Designated initializer
 *
 *  @param entry    Entry to use
 *  @param sequence Keystroke Sequence to use, this is usefull to override any sequences stored in the entry
 *
 *  @return AutotypeSequnce with the entry and keystroke in places
 */
- (instancetype)initWithEntry:(KPKEntry *)entry andSequence:(NSString *)sequence;
- (instancetype)initWithDefaultSequenceForEntry:(KPKEntry *)entry;
- (instancetype)initWithWindowAssociation:(KPKWindowAssociation *)association;

- (BOOL)isEqualToAutotypeContext:(MPAutotypeContext *)context;

@end
