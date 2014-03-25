//
//  MPAutotypeSequence.m
//  MacPass
//
//  Created by Michael Starke on 29/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeContext.h"

#import "KPKAutotype.h"
#import "KPKEntry.h"
#import "KPKWindowAssociation.h"
#import "NSString+Commands.h"

@interface MPAutotypeContext () {
  NSString *_evaluatedCommand;
}

@end

@implementation MPAutotypeContext

- (instancetype)initWithWindowAssociation:(KPKWindowAssociation *)association {
  self = [self initWithEntry:association.autotype.entry andSequence:association.keystrokeSequence];
  return self;
}

- (instancetype)initWithDefaultSequenceForEntry:(KPKEntry *)entry {
  self = [self initWithEntry:entry andSequence:entry.autotype.defaultKeystrokeSequence];
  return self;
}

- (instancetype)initWithEntry:(KPKEntry *)entry andSequence:(NSString *)sequence {
  self = [super init];
  if(self) {
    _command = [sequence copy];
    _entry = entry;
    _normalizedCommand = [[sequence normalizedAutotypeSequence] copy];
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  MPAutotypeContext *copy = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:self.command];
  return copy;
}


- (BOOL)isValid {
  return (self.normalizedCommand != nil);
}

- (NSString *)evaluatedCommand {
  if(!_evaluatedCommand) {
    NSString *placeholderFilled = [self.normalizedCommand evaluatePlaceholderWithEntry:self.entry];
    _evaluatedCommand = [[placeholderFilled resolveReferencesWithTree:self.entry.tree] copy];
  }
  return _evaluatedCommand;
}

@end
