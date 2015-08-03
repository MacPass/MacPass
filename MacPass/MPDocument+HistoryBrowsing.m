//
//  MPDocument+HistoryBrowsing.m
//  MacPass
//
//  Created by Michael Starke on 26.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"

NSString *const MPDocumentDidEnterHistoryNotification = @"MPDocumentDidEnterHistoryNotification";
NSString *const MPDocumentDidExitHistoryNotification  = @"MPDocumentDidExitHistoryNotification";

@implementation MPDocument (HistoryBrowsing)

- (void)showHistory:(id)sender {
  NSAssert(self.selectedEntry && self.selectedItem == (id)self.selectedEntry, @"Entry needs to be selected for history browsing!");
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidEnterHistoryNotification object:self];
}

- (void)exitHistory:(id)sender {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidExitHistoryNotification object:self];
}


@end
