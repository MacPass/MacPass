//
//  MPDocument+Search.m
//  MacPass
//
//  Created by Michael Starke on 25.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument+Search.h"
#import "MPDocument.h"
#import "KPKGroup.h"
#import "KPKEntry.h"
#import "MPFlagsHelper.h"

NSString *const MPDocumentDidEnterSearchNotification  = @"com.hicknhack.macpass.MPDocumentDidEnterSearchNotification";
NSString *const MPDocumentDidChangeSearchNotification = @"com.hicknhack.macpass.MPDocumentDidChangeSearchNotification";
NSString *const MPDocumentDidChangeSearchFlags        = @"com.hicknhack.macpass.MPDocumentDidChangeSearchFlagsNotification";
NSString *const MPDocumentDidExitSearchNotification   = @"com.hicknhack.macpass.MPDocumentDidExitSearchNotification";

@implementation MPDocument (Search)

#pragma mark Actions

- (void)performFindPanelAction:(id)sender {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidEnterSearchNotification object:self];
}

- (void)updateSearch:(id)sender {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidChangeSearchNotification object:self];
}

- (void)exitSearch:(id)sender {
  self.searchString = nil;
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidExitSearchNotification object:self];
}

- (void)toggleFlags:(id)sender {
  if(![sender respondsToSelector:@selector(tag)]) {
    return; // We nee to read the button tag
  }
  if([sender respondsToSelector:@selector(state)]) {
    return; // We need to read the button state
  }
  MPEntrySearchFlags toggleFlag = [sender tag];
  switch([sender state]) {
    case NSOffState:
      toggleFlag ^= MPEntrySearchAllFlags;
      break;
    case NSOnState:
      /* On is fine */
      break;
    default:
      NSAssert(NO, @"Internal state is inconsistent");
      return;
  }
  MPEntrySearchFlags newFlags = self.activeFlags & toggleFlag;
  if(newFlags == self.activeFlags) {
    self.activeFlags = (newFlags == MPEntrySearchNone) ? MPEntrySearchTitles : newFlags;
    [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidChangeSearchFlags object:self];
  }
}

#pragma mark Search
- (NSArray *)entriesInDocument:(MPDocument *)document matching:(NSString *)string {
  /* Filter double passwords */
  if(MPTestFlagInOptions(MPEntrySearchDoublePasswords, self.activeFlags)) {
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
  NSArray *predicates = [self _filterPredicatesWithString:string];
  if(predicates) {
    NSPredicate *fullFilter = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    return  [[document.root childEntries] filteredArrayUsingPredicate:fullFilter];
  }
  /* No filter, just return everything */
  return [document.root childEntries];
}

- (NSArray *)optionsEnabledInMode:(MPEntrySearchFlags)mode {
  NSArray *allOptions = @[ @(MPEntrySearchUrls), @(MPEntrySearchUsernames),
                           @(MPEntrySearchTitles), @(MPEntrySearchPasswords) ,
                           @(MPEntrySearchNotes), @(MPEntrySearchDoublePasswords) ];
  
  NSIndexSet *indexes = [allOptions indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    MPEntrySearchFlags flag = [obj integerValue];
    return MPTestFlagInOptions(flag, mode);
  }];
  return [allOptions objectsAtIndexes:indexes];
}

- (NSArray *)_filterPredicatesWithString:(NSString *)string{
  NSMutableArray *prediactes = [[NSMutableArray alloc] initWithCapacity:4];
  
  if(MPTestFlagInOptions(MPEntrySearchTitles, self.activeFlags)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.title CONTAINS[cd] %@", string]];
  }
  if(MPTestFlagInOptions(MPEntrySearchUsernames, self.activeFlags)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.username CONTAINS[cd] %@", string]];
  }
  if(MPTestFlagInOptions(MPEntrySearchUrls, self.activeFlags)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.url CONTAINS[cd] %@", string]];
  }
  if(MPTestFlagInOptions(MPEntrySearchPasswords, self.activeFlags)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.password CONTAINS[cd] %@", string]];
  }
  if(MPTestFlagInOptions(MPEntrySearchNotes, self.activeFlags)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.notes CONTAINS[cd] %@", string]];
  }
  return prediactes;
}

@end
