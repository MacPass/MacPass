//
//  MPSegmentedContextCell.m
//  MacPass
//
//  Created by Michael Starke on 13.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPSegmentedContextCell.h"

@implementation MPSegmentedContextCell

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if(self) {
    _contextMenuAction = NULL;
    _contextMenuTarget = nil;
  }
  return self;
}

- (id)init {
  self = [super init];
  if(self) {
    _contextMenuAction = NULL;
    _contextMenuTarget = nil;
  }
  return self;
}

- (SEL)action {
  if([self selectedSegment] == 1) {
    return self.contextMenuAction;
  }
  return [super action];
}

- (id)target {
  if([self selectedSegment] == 1) {
    return self.contextMenuTarget;
  }
  return [super target];
}

@end
