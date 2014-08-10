//
//  MPAutotypeHelper.h
//  MacPass
//
//  Created by Michael Starke on 10/08/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPAutotypeHelper : NSObject

/**
 *  Tests the given item for a possible wrong autotype format
 *  MacPass 0.4 and 0.4.1 did store wrong Autotype sequences and thus mangled database files
 *
 *  @param item Item to test for malformation. Allowed Items are KPKNode, KPKEntry, KPKGroup and KPKAutotype
 *
 *  @return YES if the given item is considered a possible candiate. NO in all other cases
 */
+ (BOOL)isCandidateForMalformedAutotype:(id)item;

@end
