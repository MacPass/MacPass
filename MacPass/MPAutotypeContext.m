//
//  MPAutotypeSequence.m
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

#import "MPAutotypeContext.h"

#import "KeePassKit/KeePassKit.h"

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
    _normalizedCommand = sequence.kpk_normalizedAutotypeSequence;
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  MPAutotypeContext *copy = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:self.command];
  return copy;
}

- (BOOL)isEqual:(id)object {
  return [self isEqualToAutotypeContext:object];
}

- (BOOL)isEqualToAutotypeContext:(MPAutotypeContext *)context {
  if(![context isKindOfClass:self.class]) {
    return NO;
  }
  if(KPKComparsionDifferent == [self.entry compareToEntry:context.entry]) {
    return NO;
  }
  return [self.normalizedCommand isEqualToString:context.normalizedCommand];
}

- (BOOL)valid {
  return (self.normalizedCommand != nil);
}

- (NSString *)evaluatedCommand {
  if(!_evaluatedCommand) {
    _evaluatedCommand = [[self.normalizedCommand kpk_finalValueForEntry:self.entry] copy];
  }
  return _evaluatedCommand;
}

- (NSString *)maskedEvaluatedCommand {
  NSString *passwordPlaceholder = [NSString stringWithFormat:@"{%@}",kKPKPasswordKey];
  NSString *normalized = self.normalizedCommand;
  NSString *masked = [normalized stringByReplacingOccurrencesOfString:passwordPlaceholder withString:@"•••" options:NSCaseInsensitiveSearch range:NSMakeRange(0, normalized.length)];
  return [[masked kpk_finalValueForEntry:self.entry options:KPKCommandEvaluationOptionSkipUserInteraction|KPKCommandEvaluationOptionReadOnly] copy];
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
