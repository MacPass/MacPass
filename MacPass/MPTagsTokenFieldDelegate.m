//
//  MPTagsTokenFieldDelegate.m
//  MacPass
//
//  Created by Michael Starke on 30/09/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
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

#import "MPTagsTokenFieldDelegate.h"

@implementation MPTagsTokenFieldDelegate

// Each element in the array should be an NSString or an array of NSStrings.
// substring is the partial string that is being completed.  tokenIndex is the index of the token being completed.
// selectedIndex allows you to return by reference an index specifying which of the completions should be selected initially.
// The default behavior is not to have any completions.
//- (nullable NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(nullable NSInteger *)selectedIndex;

// return an array of represented objects you want to add.
// If you want to reject the add, return an empty array.
// returning nil will cause an error.
//- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(NSUInteger)index;

// If you return nil or don't implement these delegate methods, we will assume
// editing string = display string = represented object
//- (nullable NSString *)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject;
//- (nullable NSString *)tokenField:(NSTokenField *)tokenField editingStringForRepresentedObject:(id)representedObject;
//- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString: (NSString *)editingString;

@end
