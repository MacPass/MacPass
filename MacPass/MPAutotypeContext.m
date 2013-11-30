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
  /*
   Parse the sequence to determine a possible Value?
   DELAY <seconds>
   TAB <repeat>
   VKEY <code>
   */
  if(self) {
    if(entry == nil || sequence == nil) {
      self = nil;
    }
    else {
      self.entry = entry;
      self.commandsSequence = sequence;
      NSRegularExpression *regexp = [[NSRegularExpression alloc] initWithPattern:@"{[a-z]+([0-9]*)}" options:NSRegularExpressionIgnoreMetacharacters error:0];
      if(regexp) {
        NSArray *matches = [regexp matchesInString:self.commandsSequence options:0 range:NSMakeRange(0, [self.commandsSequence length])];
        if(matches) {
        }
      }
    }
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  MPAutotypeContext *copy = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:self.commandsSequence];
  return copy;
}

@end
