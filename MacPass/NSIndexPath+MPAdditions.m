//
//  NSIndexPath+MPAdditions.m
//  MacPass
//
//  Created by Michael Starke on 07.11.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "NSIndexPath+MPAdditions.h"

@implementation NSIndexPath (MPAdditions)

- (BOOL)containsIndexPath:(NSIndexPath *)path {
  NSComparisonResult result = [self compare:path];
  if(result == NSOrderedSame) {
    return YES;
  }
  if(result == NSOrderedDescending) {
     return NO;
  }
  if(self.length == path.length) {
    return NO;
  }
  
  NSUInteger commonLength = MIN(self.length, path.length);
  for(NSUInteger position = 0; position < commonLength; position++) {
    if([self indexAtPosition:position] != [path indexAtPosition:position]) {
      return NO;
    }
  }
  return YES;
}

@end
