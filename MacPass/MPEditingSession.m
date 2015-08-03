//
//  MPEditSession.m
//  MacPass
//
//  Created by Michael Starke on 30/05/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPEditingSession.h"
#import "KPKNode.h"

@interface MPEditingSession ()

@property (strong) KPKNode *node;
@property (copy) KPKNode *rollbackNode;

@end

@implementation MPEditingSession

- (instancetype)init {
  self = [self initWithNode:nil];
  return self;
}

- (instancetype)initWithNode:(KPKNode *)node {
  self = [super init];
  if(self) {
    self.node = node;
    self.rollbackNode = node;
  }
  return self;
}

- (BOOL)hasChanges {
  return [self.node isEqual:self.rollbackNode];
}

@end
