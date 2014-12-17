//
//  MPAutotypeSequence.h
//  MacPass
//
//  Created by Michael Starke on 29/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
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
 *  Command with placeholders and references resolved
 */
@property (nonatomic, readonly, copy) NSString *evaluatedCommand;
/**
 *  @return YES if valid, NO otherwise
 */
@property (nonatomic, readonly, assign) BOOL isValid;

/**
 *  Designated initializer
 *
 *  @param entry    Entry to use
 *  @param sequence Keystroke Sequence to use
 *
 *  @return AutotypeSequnce with the entry and keystroke in places
 */
- (instancetype)initWithEntry:(KPKEntry *)entry andSequence:(NSString *)sequence;
- (instancetype)initWithDefaultSequenceForEntry:(KPKEntry *)entry;
- (instancetype)initWithWindowAssociation:(KPKWindowAssociation *)association;

@end
