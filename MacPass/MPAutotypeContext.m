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
    _normalizedCommand = sequence.normalizedAutotypeSequence;
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  MPAutotypeContext *copy = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:self.command];
  return copy;
}


- (BOOL)valid {
  return (self.normalizedCommand != nil);
}

- (NSString *)evaluatedCommand {
  if(!_evaluatedCommand) {
    _evaluatedCommand = [[self.normalizedCommand finalValueForEntry:self.entry] copy];
  }
  return _evaluatedCommand;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"command:%@\nnormalized:%@\nevaluated:%@\nentry.title:%@\nentry.uuid:%@\n",
          self.command,
          self.normalizedCommand,
          self.evaluatedCommand,
          self.entry.title,
          self.entry.uuid.UUIDString];
}

@end
