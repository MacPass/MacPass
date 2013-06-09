//
//  KdbEntry+MPTreeTools.m
//  MacPass
//
//  Created by Michael Starke on 10.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbEntry+MPTreeTools.h"

@implementation KdbEntry (MPTreeTools)

- (NSUInteger)indexInParent {
  if(self.parent) {
    return [self.parent.entries indexOfObject:self];
  }
  return NSNotFound;
}

@end
