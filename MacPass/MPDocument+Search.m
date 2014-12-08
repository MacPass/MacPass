//  MPDocument+Search.m
//
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
#import "KPKTimeInfo.h"

#import "MPFlagsHelper.h"

NSString *const MPDocumentDidEnterSearchNotification  = @"com.hicknhack.macpass.MPDocumentDidEnterSearchNotification";
NSString *const MPDocumentDidChangeSearchFlags        = @"com.hicknhack.macpass.MPDocumentDidChangeSearchFlagsNotification";
NSString *const MPDocumentDidExitSearchNotification   = @"com.hicknhack.macpass.MPDocumentDidExitSearchNotification";

NSString *const MPDocumentDidChangeSearchResults      = @"com.hicknhack.macpass.MPDocumentDidChangeSearchResults";

NSString *const kMPDocumentSearchResultsKey           = @"kMPDocumentSearchResultsKey";


@implementation MPDocument (Search)


- (void)enterSearchWithContext:(MPEntrySearchContext *)context {
  /* the search context is loaded via defaults */
  self.searchContext = context;
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSearch:) name:NSUndoManagerDidRedoChangeNotification object:self.undoManager];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSearch:) name:NSUndoManagerDidUndoChangeNotification object:self.undoManager];
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidEnterSearchNotification object:self];
  [self updateSearch:self];
}

#pragma mark Actions

- (void)performFindPanelAction:(id)sender {
  [self enterSearchWithContext:[MPEntrySearchContext userContext]];
}

- (void)updateSearch:(id)sender {
  if(NO == self.hasSearch) {
    [self enterSearchWithContext:[MPEntrySearchContext userContext]];
    return; // We get called back!
  }
  MPDocumentWindowController *windowController = [self windowControllers][0];
  NSString *searchString = [windowController.searchField stringValue];
  self.searchContext.searchString = searchString;
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
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUndoManagerDidUndoChangeNotification object:self.undoManager];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUndoManagerDidRedoChangeNotification object:self.undoManager];
  self.searchContext = nil;
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
  BOOL isSingleFlag = toggleFlag & MPEntrySearchSingleFlags;
  NSButton *button = sender;
  switch([button state]) {
    case NSOffState:
      toggleFlag ^= MPEntrySearchAllCombineableFlags;
      newFlags = isSingleFlag ? MPEntrySearchNone : (self.searchContext.searchFlags & toggleFlag);
      break;
    case NSOnState:
      if(isSingleFlag ) {
        newFlags = toggleFlag; // This has to be either expired or double passwords
      }
      else {
        /* always mask the double passwords in case another button was pressed */
        newFlags = self.searchContext.searchFlags | toggleFlag;
        newFlags &= (MPEntrySearchSingleFlags ^ MPEntrySearchAllFlags);
      }
      break;
    default:
      NSAssert(NO, @"Internal state is inconsistent");
      return;
  }
  if(newFlags != self.searchContext.searchFlags) {
    self.searchContext.searchFlags = (newFlags == MPEntrySearchNone) ? MPEntrySearchTitles : newFlags;
    [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidChangeSearchFlags object:self];
    [self updateSearch:self];
  }
}

- (NSArray *)entriesMatchingSearch:(MPEntrySearchContext *)search {
  return nil;
}

#pragma mark Search
- (NSArray *)_findEntriesMatchingCurrentSearch {
  /* Filter double passwords */
  if(MPIsFlagSetInOptions(MPEntrySearchDoublePasswords, self.searchContext.searchFlags)) {
    __block NSMutableDictionary *passwordToEntryMap = [[NSMutableDictionary alloc] initWithCapacity:100];
    /* Build up a usage map */
    [[self.root searchableChildEntries] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      KPKEntry *entry = obj;
      /* skip entries without passwords */
      if([entry.password length] > 0) {
        NSMutableSet *entrySet = passwordToEntryMap[entry.password];
        if(entrySet) {
          [entrySet addObject:entry];
        }
        else {
          passwordToEntryMap[entry.password] = [NSMutableSet setWithObject:entry];
        }
      }
    }];
    /* check for usage count */
    __block NSMutableArray *doublePasswords = [[NSMutableArray alloc] init];
    [[passwordToEntryMap allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      NSSet *entrySet = passwordToEntryMap[obj];
      if([entrySet count] > 1) {
        [doublePasswords addObjectsFromArray:[entrySet allObjects]];
      }
    }];
    return doublePasswords;
  }
  if(MPIsFlagSetInOptions(MPEntrySearchExpiredEntries, self.searchContext.searchFlags)) {
    NSPredicate *expiredPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
      KPKNode *node = evaluatedObject;
      return node.timeInfo.isExpired;
    }];
    return [[self.root searchableChildEntries] filteredArrayUsingPredicate:expiredPredicate];
  }
  /* Filter using predicates */
  NSArray *predicates = [self _filterPredicatesWithString:self.searchContext.searchString];
  if(predicates) {
    NSPredicate *fullFilter = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    return [[self.root searchableChildEntries] filteredArrayUsingPredicate:fullFilter];
  }
  /* No filter, just return everything */
  return [self.root searchableChildEntries];
}

- (NSArray *)_filterPredicatesWithString:(NSString *)string{
  NSMutableArray *prediactes = [[NSMutableArray alloc] initWithCapacity:4];
  
  if(MPIsFlagSetInOptions(MPEntrySearchTitles, self.searchContext.searchFlags)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.title CONTAINS[cd] %@", string]];
  }
  if(MPIsFlagSetInOptions(MPEntrySearchUsernames, self.searchContext.searchFlags)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.username CONTAINS[cd] %@", string]];
  }
  if(MPIsFlagSetInOptions(MPEntrySearchUrls, self.searchContext.searchFlags)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.url CONTAINS[cd] %@", string]];
  }
  if(MPIsFlagSetInOptions(MPEntrySearchPasswords, self.searchContext.searchFlags)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.password CONTAINS[cd] %@", string]];
  }
  if(MPIsFlagSetInOptions(MPEntrySearchNotes, self.searchContext.searchFlags)) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.notes CONTAINS[cd] %@", string]];
  }
  return prediactes;
}

@end
