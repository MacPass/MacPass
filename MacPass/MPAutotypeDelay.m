//
//  MPAutotypeDelay.m
//  MacPass
//
//  Created by Michael Starke on 20/08/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
