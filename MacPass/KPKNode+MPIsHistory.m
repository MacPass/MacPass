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
  /* nil call will return NO */
  return self.asEntry.isHistory;
}

@end
