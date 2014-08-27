//
//  MPFlagsHelper.m
//  MacPass
//
//  Created by Michael Starke on 27/08/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPFlagsHelper.h"

BOOL MPTestFlagInOptions(const NSUInteger flag, const NSUInteger options ) {
  return (0 != (options & flag));
}
