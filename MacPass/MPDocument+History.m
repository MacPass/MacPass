//
//  MPDocument+HistoryBrowsing.m
//  MacPass
//
//  Created by Michael Starke on 26.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
  [self.undoManager setActionName:NSLocalizedString(@"RESTORE_HISTORY_ENTRY", "Action to restore an Entry to its previous state of it's history")];
}

@end
