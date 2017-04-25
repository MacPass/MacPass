//
//  KPKNode+MPIsHistory.m
//  MacPass
//
//  Created by Michael Starke on 25.04.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "KPKNode+MPIsHistory.h"

@implementation KPKNode (MPIsHistory)


- (BOOL)isHistory {
  if(self.asEntry) {
    return self.asEntry.isHistory;
  }
  return NO;
}

@end
