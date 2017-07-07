//
//  MPTagsTokenFieldDelegate.m
//  MacPass
//
//  Created by Michael Starke on 30/09/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
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
