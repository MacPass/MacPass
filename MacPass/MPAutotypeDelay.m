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

- (NSString *)description {
  return [[NSString alloc] initWithFormat:@"%@ delay: %ld ms", [self class], _delay];
}

- (instancetype)initWithDelay:(NSUInteger)delay {
  self = [super init];
  if(self) {
    /* Delays longer than a minute are a bit long */
    _delay = MIN(60,delay);
  }
  return self;
}

- (void)execute {
  usleep((useconds_t)(_delay*NSEC_PER_MSEC));
}

@end
