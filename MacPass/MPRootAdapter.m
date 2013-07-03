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

@property (strong) NSArray *groups;

@end

@implementation MPRootAdapter


- (void)setTree:(KdbTree *)tree {
  if(_tree != tree) {
    _tree = tree;
    self.groups = @[_tree.root];
  }
}

- (NSArray *)entries {
  return nil;
}
@end
