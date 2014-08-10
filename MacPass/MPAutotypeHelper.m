//
//  MPAutotypeHelper.m
//  MacPass
//
//  Created by Michael Starke on 10/08/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeHelper.h"

#import "KPKGroup.h"
#import "KPKEntry.h"

#import "KPKAutotype.h"
#import "KPKWindowAssociation.h"

@implementation MPAutotypeHelper

+ (BOOL)isCandidateForMalformedAutotype:(id)item {
  
  NSString *keystrokeSequence;
  if([item isKindOfClass:[KPKEntry class]] && ![((KPKEntry *)item).autotype hasDefaultKeystrokeSequence]) {
    keystrokeSequence = ((KPKEntry *)item).autotype.defaultKeystrokeSequence;
  }
  else if( [item isKindOfClass:[KPKGroup class]] && ![item hasDefaultAutotypeSequence]) {
    keystrokeSequence = ((KPKGroup *)item).defaultAutoTypeSequence;
  }
  else if( [item isKindOfClass:[KPKWindowAssociation class]] && ![item hasDefaultKeystrokeSequence]){
    keystrokeSequence = ((KPKWindowAssociation *)item).keystrokeSequence;
  }
  /* if nothing is true, keystrokeSequence is nil an hence return is NO */
  return (NSOrderedSame == [@"{TAB}{USERNAME}{TAB}{PASSWORD}{ENTER}" compare:keystrokeSequence options:NSCaseInsensitiveSearch]);
}

@end
