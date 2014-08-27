//
//  MPEntrySearch.h
//  MacPass
//
//  Created by Michael Starke on 26.06.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, MPEntrySearchFlags) {
  MPEntrySearchNone            = 0,
  MPEntrySearchUrls            = (1<<0),
  MPEntrySearchUsernames       = (1<<1),
  MPEntrySearchTitles          = (1<<2),
  MPEntrySearchPasswords       = (1<<3),
  MPEntrySearchNotes           = (1<<4),
  MPEntrySearchAllAttributes   = (1<<5),
  /* The following two flags should be used like enums.
   They are not intented to be used in conjunktion with any other flag */
  MPEntrySearchDoublePasswords = (1<<6),
  MPEntrySearchExpiredEntries  = (1<<7),
  /* All search flags that are combineable combined */
  MPEntrySearchAllFlags        = (MPEntrySearchDoublePasswords |
                                  MPEntrySearchExpiredEntries |
                                  MPEntrySearchNotes |
                                  MPEntrySearchPasswords |
                                  MPEntrySearchTitles |
                                  MPEntrySearchUrls |
                                  MPEntrySearchUsernames |
                                  MPEntrySearchAllAttributes )
};


/* Wrap serach criteria to be able to store them */
@interface MPEntrySearchContext : NSObject <NSSecureCoding,NSCopying>

/**
 *  Returns a default search context initalized with sane values.
 *
 *  @return The default search context
 */
+ (instancetype)defaultContext;
/**
 *  Returns the search context using the users preferences. If none are found, a default context is created
 *
 *  @return Search context configured to the users data. If nothing is configures, defaultContext is used
 */
+ (instancetype)userContext;

- (instancetype)initWithString:(NSString *)searchString flags:(MPEntrySearchFlags)flags;

@property (nonatomic, assign) NSInteger searchFlags;
@property (nonatomic, copy) NSString *searchString;

@end
