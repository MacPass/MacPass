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

@property (copy) KPKNode *node;
@property (weak) KPKNode *source;

@end

@implementation MPEditingSession

+ (instancetype)editingSessionWithSource:(KPKNode *)node {
  return [[MPEditingSession alloc] initWithSource:node];
}

- (instancetype)initWithSource:(KPKNode *)node {
  self = [super init];
  if(self) {
    self.node = node;
    self.source = node;
  }
  return self;
}

- (BOOL)hasChanges {
  return ![self.node isEqual:self.source];
}

@end
