//
//  MPDocument+Search.m
//  MacPass
//
//  Created by Michael Starke on 25.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument+Search.h"
#import "MPDocument.h"
#import "MPDocumentWindowController.h"

#import "KPKGroup.h"
#import "KPKEntry.h"

#import "MPFlagsHelper.h"

NSString *const MPDocumentDidEnterSearchNotification  = @"com.hicknhack.macpass.MPDocumentDidEnterSearchNotification";
NSString *const MPDocumentDidChangeSearchFlags        = @"com.hicknhack.macpass.MPDocumentDidChangeSearchFlagsNotification";
NSString *const MPDocumentDidExitSearchNotification   = @"com.hicknhack.macpass.MPDocumentDidExitSearchNotification";

NSString *const MPDocumentDidChangeSearchResults      = @"com.hicknhack.macpass.MPDocumentDidChangeSearchResults";

NSString *const kMPDocumentSearchResultsKey           = @"kMPDocumentSearchResultsKey";


@implementation MPDocument (Search)

#pragma mark Actions

- (void)performFindPanelAction:(id)sender {
  self.hasSearch = YES;
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidEnterSearchNotification object:self];
  [self updateSearch:self];
}

- (void)updateSearch:(id)sender {
  MPDocumentWindowController *windowController = [self windowControllers][0];
  self.searchString = [windowController.searchField stringValue];
  if(NO == self.hasSearch) {
    [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidEnterSearchNotification object:self];
  }
  self.hasSearch = YES;
  MPDocument __weak *weakSelf = self;
  dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(backgroundQueue, ^{
    NSArray *results = [weakSelf _findEntriesMatchingCurrentSearch];
    dispatch_sync(dispatch_get_main_queue(), ^{
      weakSelf.selectedEntry = nil;
      [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidChangeSearchResults object:weakSelf userInfo:@{ kMPDocumentSearchResultsKey: results }];
    });
  });
}

- (void)exitSearch:(id)sender {
  self.searchString = nil;
  self.hasSearch = NO;
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidExitSearchNotification object:self];
}

- (void)toggleSearchFlags:(id)sender {
  if(![sender respondsToSelector:@selector(tag)]) {
    return; // We need to read the button tag
  }
  if(![sender respondsToSelector:@selector(state)]) {
    return; // We need to read the button state
  }
  MPEntrySearchFlags toggleFlag = [sender tag];
  MPEntrySearchFlags newFlags = MPEntrySearchNone;
  switch([sender state]) {
    case NSOffState:
      toggleFlag ^= MPEntrySearchAllFlags;
      newFlags = self.activeFlags & toggleFlag;
      break;
    case NSOnState:
      newFlags = self.activeFlags | toggleFlag;
      break;
    default:
      NSAssert(NO, @"Internal state is inconsistent");
      return;
  }
  if(newFlags != self.activeFlags) {
    self.activeFlags = (newFlags == MPEntrySearchNone) ? MPEntrySearchTitles : newFlags;
    [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidChangeSearchFlags object:self];
    [self updateSearch:self];
  }
}

#pragma mark Search
- (NSArray *)_findEntriesMatchingCurrentSearch {
  /* Filter double passwords */
  MPDocument __weak *weakSelf = self;
  if(MPTestFlagInOptions(MPEntrySearchDoublePasswords, self.activeFlags)) {
    __block NSMutableDictionary *passwordToEntryMap;
    /* Build up a usage map */
    [[weakSelf.root childEntries] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
  NSArray *predicates = [self _filterPredicatesWithString:self.searchString];
  if(predicates) {
    NSPredicate *fullFilter = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    return [[self.root childEntries] filteredArrayUsingPredicate:fullFilter];
  }
  /* No filter, just return everything */
  return [self.root childEntries];
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
