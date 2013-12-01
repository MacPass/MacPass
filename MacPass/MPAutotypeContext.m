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

@interface MPAutotypeContext ()

@property (nonatomic, assign) BOOL isCommand;

@end

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
      NSError *error;
      NSRegularExpression *regexp = [[NSRegularExpression alloc] initWithPattern:@"\\{([a-z]+) ?([0-9]*)\\}" options:NSRegularExpressionCaseInsensitive error:&error];
      if(regexp) {
        [regexp enumerateMatchesInString:sequence options:0 range:NSMakeRange(0, [sequence length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
          NSRange commandRange = [result rangeAtIndex:1];
          NSRange valueRange = [result rangeAtIndex:2];
          if(commandRange.location != NSNotFound && commandRange.length != 0) {
            self.command = [sequence substringWithRange:commandRange];
            self.isCommand = YES;
          }
          if(valueRange.location != NSNotFound && valueRange.length != 0) {
            self.value = [[sequence substringWithRange:valueRange] integerValue];
          }
          else {
            self.value = NSNotFound;
          }
        }];
      }
      else {
        NSLog(@"Error while trying to parse Autotype sequence: %@", [error localizedDescription]);
      }
      
    }
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  MPAutotypeContext *copy = [[MPAutotypeContext alloc] initWithEntry:self.entry andSequence:self.command];
  return copy;
}

@end
