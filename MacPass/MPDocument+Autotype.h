//
//  MPDocument+Autotype.h
//  MacPass
//
//  Created by Michael Starke on 01/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"

@interface MPDocument (Autotype)
/*
 Problem:
 
 If matching isn't safe, we need to determine what to do:
 Possible selections for the user are Window associations or entries
 Hence we need to deliver both - or do something completely different?

 */
- (NSArray *)findEntriesForWindowTitle:(NSString *)windowTitle;

@end
