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
  for(KPKEntry *entry in autotypeEntries) {
    //KPKAutotype *autotype = entry.autotype;
  }
  return nil;
}

@end
