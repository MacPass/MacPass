//
//  MPFlagsHelper.h
//  MacPass
//
//  Created by Michael Starke on 28/01/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#ifndef MacPass_MPFlagsHelper_h
#define MacPass_MPFlagsHelper_h

#include <Foundation/Foundation.h>
/**
 *  Tests if the given flag is set in the mode options.
 *  The test operates on bit flag left. Hence it will return YES
 *  if only one single bit is common in both parameters!
 *
 *  @param options single flag to test for
 *  @param flag options to test for flag
 *
 *  @return YES if any bit of flag is set in mode
 */
FOUNDATION_EXTERN BOOL MPIsFlagSetInOptions(const NSUInteger flag, const NSUInteger options );
#endif
