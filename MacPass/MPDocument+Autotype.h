//
//  MPDocument+Autotype.h
//  MacPass
//
//  Created by Michael Starke on 01/11/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"

@interface MPDocument (Autotype)

- (NSArray *)findEntriesForWindowTitle:(NSString *)windowTitle;

@end
