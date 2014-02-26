//
//  MPDocument+HistoryBrowsing.h
//  MacPass
//
//  Created by Michael Starke on 26.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"

FOUNDATION_EXPORT NSString *const MPDocumentDidEnterHistoryNotification;
FOUNDATION_EXPORT NSString *const MPDocumentDidExitHistoryNotification;

@interface MPDocument (HistoryBrowsing)

- (IBAction)showHistory:(id)sender;
- (IBAction)exitHistory:(id)sender;

@end
