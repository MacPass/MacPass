//
//  MPDocument+EditingSession.h
//  MacPass
//
//  Created by Michael Starke on 30/05/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"

@class MPEditingSession;

@interface MPDocument (EditingSession)

- (BOOL)hasActiveSession;
- (void)cancelEditingSession;
- (void)commitEditingSession;

@end
