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
  MPEntrySearchDoublePasswords = (1<<6), // Unused in GUI for now
  MPEntrySearchExpiredEntries  = (1<<7), // Unused for now
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
@interface MPEntrySearchContext : NSObject <NSSecureCoding>

+ (instancetype)defaultContext;
- (instancetype)initWithString:(NSString *)searchString flags:(MPEntrySearchFlags)flags;

@property (readonly, assign) NSInteger searchFlags;
@property (readonly, copy) NSString *searchString;

@end
