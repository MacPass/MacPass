//
//  MPSearchHelper.h
//  MacPass
//
//  Created by Michael Starke on 24/01/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPDocument;

FOUNDATION_EXTERN NSString *const MPDocumentSearchServiceDidChangeSearchNotification;
FOUNDATION_EXTERN NSString *const MPDocumentSearchServiceDidClearSearchNotification;
FOUNDATION_EXTERN NSString *const MPDocumentSearchServiceDidExitSearchNotification;

typedef NS_OPTIONS(NSUInteger, MPEntrySearchFlags) {
  MPEntrySearchNone            = 0,
  MPEntrySearchUrls            = (1<<0),
  MPEntrySearchUsernames       = (1<<1),
  MPEntrySearchTitles          = (1<<2),
  MPEntrySearchPasswords       = (1<<3),
  MPEntrySearchNotes           = (1<<4),
  MPEntrySearchDoublePasswords = (1<<5)
};

@interface MPDocumentSearchService : NSObject

@property (nonatomic, assign) MPEntrySearchFlags activeFlags;
@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, weak) NSSearchField *searchField;

+ (instancetype)sharedService;
- (NSArray *)entriesInDocument:(MPDocument *)document matching:(NSString *)string usingSearchMode:(MPEntrySearchFlags)mode;
- (NSArray *)optionsEnabledInMode:(MPEntrySearchFlags)mode;

/* Should be called by the NSSearchTextField to update the search string */
- (IBAction)updateSearch:(id)sender;
/* Clears the search string, but doesn't exit searching */
- (IBAction)clearSearch:(id)sender;
/* exits searching mode */
- (IBAction)exitSearch:(id)sender;

@end
