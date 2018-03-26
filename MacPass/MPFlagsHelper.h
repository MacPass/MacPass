//
//  MPFlagsHelper.h
//  MacPass
//
//  Created by Michael Starke on 28/01/14.
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
