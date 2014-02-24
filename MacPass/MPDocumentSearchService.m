//
//  MPSearchHelper.m
//  MacPass
//
//  Created by Michael Starke on 24/01/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocumentSearchService.h"
#import "MPDocument.h"
#import "KPKGroup.h"
#import "KPKEntry.h"
#import "MPFlagsHelper.h"

NSString *const MPDocumentSearchServiceDidChangeSearchNotification = @"com.hicknhack.macpass.MPDocumentSearchServiceDidChangeSearchNotification";
NSString *const MPDocumentSearchServiceDidClearSearchNotification = @"com.hicknhack.macpass.MPDocumentSearchServiceDidClearSearchNotification";
NSString *const MPDocumentSearchServiceDidExitSearchNotification = @"com.hicknhack.macpass.MPDocumentSearchServiceDidExitSearchNotification";

@implementation MPDocumentSearchService

static MPDocumentSearchService *_kMPSearchServiceInstance;

+ (instancetype)sharedService {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _kMPSearchServiceInstance = [[MPDocumentSearchService alloc] init];
  });
  return _kMPSearchServiceInstance;
}

- (instancetype)init {
  NSAssert(_kMPSearchServiceInstance == nil, @"only one shared instance allowed");
  self = [super init];
  if(self) {
    _activeFlags = MPEntrySearchTitles; // Default search is set to titles
  }
  return self;
}

#pragma mark Actions
- (void)updateSearch:(id)sender {
  if(sender != self.searchField) {
    return; // Wrong sender
  }
  self.searchString = [self.searchField stringValue];
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentSearchServiceDidChangeSearchNotification object:self];
}

- (void)clearSearch:(id)sender {
  if(sender != self.searchField) {
    return; // Wrong sender
  }
  [self.searchField setStringValue:@""];
  self.searchString = nil;
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentSearchServiceDidClearSearchNotification object:self];
}

- (void)exitSearch:(id)sender {
  [self.searchField setStringValue:@""];
  self.searchString = nil;
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentSearchServiceDidExitSearchNotification object:self];
}

- (NSArray *)entriesInDocument:(MPDocument *)document matching:(NSString *)string usingSearchMode:(MPEntrySearchFlags)mode {
  /* Filter double passwords */
  if(MPTestFlagInOptions(MPEntrySearchDoublePasswords, mode)) {
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
  NSArray *predicates = [self _filterPredicatesForMode:mode withString:string];
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

- (NSArray *)_filterPredicatesForMode:(MPEntrySearchFlags)mode withString:(NSString *)string{
  NSMutableArray *prediactes = [[NSMutableArray alloc] initWithCapacity:4];
  
  if(MPTestFlagInOptions(MPEntrySearchTitles, mode)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.title CONTAINS[cd] %@", string]];
  }
  if(MPTestFlagInOptions(MPEntrySearchUsernames, mode)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.username CONTAINS[cd] %@", string]];
  }
  if(MPTestFlagInOptions(MPEntrySearchUrls, mode)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.url CONTAINS[cd] %@", string]];
  }
  if(MPTestFlagInOptions(MPEntrySearchPasswords, mode)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.password CONTAINS[cd] %@", string]];
  }
  if(MPTestFlagInOptions(MPEntrySearchNotes, mode)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.notes CONTAINS[cd] %@", string]];
  }
  return prediactes;
}

@end
