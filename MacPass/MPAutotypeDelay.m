//
//  MPAutotypeDelay.m
//  MacPass
//
//  Created by Michael Starke on 20/08/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeDelay.h"

@interface MPAutotypeDelay ()
@property (readwrite) NSUInteger delay;
@end

@implementation MPAutotypeDelay

- (id)init {
  self = [self initWithDelay:0];
  return self;
}

- (NSString *)description {
  return [[NSString alloc] initWithFormat:@"%@ delay: %ld ms", self.class, self.delay];
}

- (instancetype)initWithDelay:(NSUInteger)delay {
  self = [super init];
  if(self) {
    /* Delays longer than a minute are a bit long */
    _delay = MIN(60*1000,delay);
  }
  return self;
}

- (void)execute {
  /* milliseconds * 10000 = microseconds */
  usleep((useconds_t)(self.delay*1000));
}

@end
