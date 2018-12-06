//
//  MPAutotypeExectutionContext.m
//  MacPass
//
//  Created by Michael Starke on 06.12.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeExecutionContext.h"

@interface MPAutotypeExecutionContext ()

@property (readwrite) pid_t targetPid;

@end

@implementation MPAutotypeExecutionContext

- (instancetype)initWithTargetPid:(pid_t)pid {
  self = [super init];
  if(self) {
    self.targetPid = pid;
  }
  return self;
}

@end
