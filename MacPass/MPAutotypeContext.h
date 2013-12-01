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

@interface MPAutotypeContext : NSObject <NSCopying>

@property (nonatomic, strong) KPKEntry *entry;
@property (nonatomic, copy) NSString *command;
@property (nonatomic, assign, readonly) BOOL isCommand;
@property (nonatomic, assign) NSInteger value;

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
