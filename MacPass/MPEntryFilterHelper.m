//
//  MPSearchHelper.m
//  MacPass
//
//  Created by Michael Starke on 24/01/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPEntryFilterHelper.h"
#import "MPDocument.h"
#import "KPKGroup.h"
#import "KPKEntry.h"
#import "MPFlagsHelper.h"

@implementation MPEntryFilterHelper

+ (NSArray *)entriesInDocument:(MPDocument *)document matching:(NSString *)filter usingFilterMode:(MPFilterMode)mode {
  /* Filter double passwords */
  if(MPTestFlagInOptions(MPFilterDoublePasswords, mode)) {
    __block NSMutableDictionary *passwordToEntryMap;
    /* Build up a usage map */
    [[document.root childEntries] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      KPKEntry *entry = obj;
      NSMutableSet *entrySet = passwordToEntryMap[entry.password];
      if(entrySet) {
        [entrySet addObject:entry];
      }
      else {
        passwordToEntryMap[entry.password] = [NSMutableSet setWithObject:entry];
      }
    }];
    /* check for usage count */
    __block NSMutableArray *doublePasswords = [[NSMutableArray alloc] init];
    [[passwordToEntryMap allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      NSSet *entrySet = passwordToEntryMap[obj];
      KPKEntry *entry = [entrySet anyObject];
      if(entry) {
        [doublePasswords addObject:entry];
      }
    }];
    return doublePasswords;
  }
  /* Filter using predicates */
  NSArray *predicates = [self _filterPredicatesForMode:mode withFilter:filter];
  if(predicates) {
    NSPredicate *fullFilter = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    return  [[document.root childEntries] filteredArrayUsingPredicate:fullFilter];
  }
  /* No filter, just return everything */
  return [document.root childEntries];
}

+ (NSArray *)optionsEnabledInMode:(MPFilterMode)mode {
  NSArray *allOptions = @[ @(MPFilterUrls), @(MPFilterUsernames),
                           @(MPFilterTitles), @(MPFilterPasswords) ,
                           @(MPFilterNotes), @(MPFilterDoublePasswords) ];

  NSIndexSet *indexes = [allOptions indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    MPFilterMode flag = [obj integerValue];
    return MPTestFlagInOptions(flag, mode);
  }];
  return [allOptions objectsAtIndexes:indexes];
}

+ (NSArray *)_filterPredicatesForMode:(MPFilterMode)mode withFilter:(NSString *)filter{
  NSMutableArray *prediactes = [[NSMutableArray alloc] initWithCapacity:4];
  
  if(MPTestFlagInOptions(MPFilterTitles, mode)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.title CONTAINS[cd] %@", filter]];
  }
  if(MPTestFlagInOptions(MPFilterUsernames, mode)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.username CONTAINS[cd] %@", filter]];
  }
  if(MPTestFlagInOptions(MPFilterUrls, mode)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.url CONTAINS[cd] %@", filter]];
  }
  if(MPTestFlagInOptions(MPFilterPasswords, mode)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.password CONTAINS[cd] %@", filter]];
  }
  if(MPTestFlagInOptions(MPFilterNotes, mode)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.notes CONTAINS[cd] %@", filter]];
  }
  return prediactes;
}

@end
