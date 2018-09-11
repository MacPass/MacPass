//
//  MPCustomFieldTableView.m
//  MacPass
//
//  Created by Michael Starke on 11.09.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPCustomFieldTableView.h"

@implementation MPCustomFieldTableView

- (NSSize)intrinsicContentSize {
  if(@available(macOS 10.12, *)) {
    return [super intrinsicContentSize];
  }
  if(self.numberOfRows > 0) {
    return NSMakeSize(-1, self.numberOfRows * self.rowHeight);
  }
  return NSMakeSize(-1, -1);
  
}

@end
