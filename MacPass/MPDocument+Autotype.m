//
//  MPDocument+Autotype.m
//  MacPass
//
//  Created by Michael Starke on 01/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument+Autotype.h"

#import "KPKGroup.h"
#import "KPKEntry.h"
#import "KPKAutotype.h"

@implementation MPDocument (Autotype)

- (NSArray *)findEntriesForWindowTitle:(NSString *)windowTitle {
  NSArray *autotypeEntries = [self.root autotypeableChildEntries];
  NSMutableArray *matchingEntries = [[NSMutableArray alloc] initWithCapacity:ceil([autotypeEntries count] / 4.0)];
  for(KPKEntry *entry in autotypeEntries) {
    /* Test for title */
    NSRange titleRange = [entry.title rangeOfString:windowTitle options:NSCaseInsensitiveSearch];
    if(titleRange.location != NSNotFound) {
      [matchingEntries addObject:entry];
    }
    /* search in Autotype entries for match */
    else {
    }
  }
  return nil;
}

@end
