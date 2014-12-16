//
//  MPDocument+Autotype.h
//  MacPass
//
//  Created by Michael Starke on 01/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
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

#import "MPDocument.h"

@interface MPDocument (Autotype)

/**
*  Tests the given item for a possible wrong autotype format
*  MacPass 0.4 and 0.4.1 did store wrong Autotype sequences and thus mangled database files
*
*  @param item Item to test for malformation. Allowed Items are KPKNode, KPKEntry, KPKGroup and KPKAutotype
*
*  @return YES if the given item is considered a possible candidate. NO in all other cases
*/
+ (BOOL)isCandidateForMalformedAutotype:(id)item;

/**
 *  Returns an NSArray containing all Autotype Contexts that match the given window title.
 *  If no entry is set, all entries in the document will be searched
 *
 *  @param windowTitle Window title to search matches for
 *  @param entry       Entry to use for lookup. If nil lookup will be performed in complete document
 *
 *  @return NSArray of MPAutotypeContext objects matching the window title.
 */
- (NSArray *)autotypContextsForWindowTitle:(NSString *)windowTitle preferredEntry:(KPKEntry *)entryOrNil;
/**
 *  Checks if the document has malformed autotype items
 *
 *  @return YES if any malformed items are found
 */
- (BOOL)hasMalformedAutotypeItems;

- (NSArray *)malformedAutotypeItems;

@end
