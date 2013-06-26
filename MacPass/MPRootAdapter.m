//
//  MPRootAdapter.m
//  MacPass
//
//  Created by Michael Starke on 26.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPRootAdapter.h"
#import "Kdb.h"

@interface MPRootAdapter ()

@property (retain) NSArray *groups;

@end

@implementation MPRootAdapter

- (void)dealloc {
  [_groups release];
  [super dealloc];
}

- (void)setTree:(KdbTree *)tree {
  if(_tree != tree) {
    [_tree release];
    _tree = [tree retain];
    self.groups = @[_tree.root];
  }
}

@end
