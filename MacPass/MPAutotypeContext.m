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

@implementation MPAutotypeContext

- (instancetype)initWithWindowAssociation:(KPKWindowAssociation *)association {
  self = [self initWithEntry:association.autotype.entry andSequence:association.keystrokeSequence];
  return self;
}

- (instancetype)initWithDefaultSequenceForEntry:(KPKEntry *)entry {
  self = [self initWithEntry:entry andSequence:entry.autotype.defaultSequence];
  return self;
}

- (instancetype)initWithEntry:(KPKEntry *)entry andSequence:(NSString *)sequence {
  self = [super init];
  if(self) {
    _command = [[sequence normalizedAutotypeSequence] copy];
    _entry = entry;
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  MPAutotypeContext *copy = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:self.command];
  return copy;
}

@end
