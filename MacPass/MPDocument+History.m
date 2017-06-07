//
//  MPDocument+HistoryBrowsing.m
//  MacPass
//
//  Created by Michael Starke on 26.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"

NSString *const MPDocumentShowEntryHistoryNotification = @"MPDocumentShowEntryHistoryNotification";
NSString *const MPDocumentHideEntryHistoryNotification  = @"MPDocumentHideEntryHistoryNotification";

@implementation MPDocument (History)

- (void)showEntryHistory:(id)sender {
  id<MPTargetNodeResolving> resolver = [NSApp targetForAction:@selector(currentTargetEntries)];
  NSArray *entries = resolver.currentTargetEntries;
  if(entries.count != 1) {
    return; // only single selection is used
  }
  if(self.hasSearch) {
    [self exitSearch:sender];
  }
  self.historyEntry = entries.firstObject;
  if(self.historyEntry) {
    [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentShowEntryHistoryNotification
                                                        object:self
                                                      userInfo:@{ MPDocumentEntryKey: self.historyEntry }];
  }
}

- (void)hideEntryHistory:(id)sender {
  self.historyEntry = nil;
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentHideEntryHistoryNotification
                                                      object:self];
}

- (void)revertEntry:(KPKEntry *)entry toEntry:(KPKEntry *)historyEntry {
  [entry pushHistory];
  [entry revertToEntry:historyEntry];
  [self.undoManager setActionName:NSLocalizedString(@"RESTORE_HISTORY_ENTRY", "Action to restore and Entry to a previous state of it's history")];
}

@end
