//
//  MPDocument+Search.h
//  MacPass
//
//  Created by Michael Starke on 25.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"

@class MPEntrySearchContext;

FOUNDATION_EXTERN NSString *const MPDocumentDidEnterSearchNotification;
FOUNDATION_EXTERN NSString *const MPDocumentDidChangeSearchFlags;
FOUNDATION_EXTERN NSString *const MPDocumentDidExitSearchNotification;
/**
 *  Posted by the document, when the search results have been updated. This is only called when searching.
 *  If the search is exited, it will be notified by MPDocumentDidExitSearchNotification
 *  The userInfo dictionary has one key kMPDocumentSearchResultsKey with an NSArray of KPKEntries matching the search.
 */
FOUNDATION_EXTERN NSString *const MPDocumentDidChangeSearchResults;

/* keys used in userInfo dictionaries on notifications */
FOUNDATION_EXTERN NSString *const kMPDocumentSearchResultsKey;

@interface MPDocument (Search)

- (void)enterSearchWithContext:(MPEntrySearchContext *)context;

/* Should be called by the NSSearchTextField to update the search string */
- (IBAction)updateSearch:(id)sender;
/* exits searching mode */
- (IBAction)exitSearch:(id)sender;
/* called by the filter toggle buttons */
- (IBAction)toggleSearchFlags:(id)sender;

@end
