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

@implementation MPDocument (HistoryBrowsing)

- (void)showEntryHistory:(id)sender {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentShowEntryHistoryNotification object:self];
}

- (void)hideEntryHistory:(id)sender {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentHideEntryHistoryNotification object:self];
}


@end
