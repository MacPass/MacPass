//
//  MPAutotypeDelay.m
//  MacPass
//
//  Created by Michael Starke on 20/08/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeDelay.h"

@interface MPAutotypeDelay () {
@private
  NSUInteger _delay;
}
@end

@implementation MPAutotypeDelay

- (id)init {
  self = [self initWithDelay:0];
  return self;
}

- (instancetype)initWithDelay:(NSUInteger)delay {
  self = [super init];
  if(self) {
    _delay = delay;
  }
  return self;
}

- (void)execute {
  usleep((useconds_t)(_delay*1000*1000));
}

@end
