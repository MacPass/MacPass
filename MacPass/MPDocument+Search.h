//
//  MPDocument+Search.h
//  MacPass
//
//  Created by Michael Starke on 25.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"

FOUNDATION_EXPORT NSString *const MPDocumentDidEnterSearchNotification;
FOUNDATION_EXTERN NSString *const MPDocumentDidChangeSearchNotification;
FOUNDATION_EXPORT NSString *const MPDocumentDidChangeSearchFlags;
FOUNDATION_EXTERN NSString *const MPDocumentDidExitSearchNotification;

@interface MPDocument (Search)

- (NSArray *)entriesInDocument:(MPDocument *)document matching:(NSString *)string;

/* Should be called by the NSSearchTextField to update the search string */
- (IBAction)updateSearch:(id)sender;
/* exits searching mode */
- (IBAction)exitSearch:(id)sender;
/* called by the filter toggle buttons */
- (IBAction)toggleFlags:(id)sender;

@end
