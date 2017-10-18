//
//  MPEntrySearch.h
//  MacPass
//
//  Created by Michael Starke on 26.06.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, MPEntrySearchFlags) {
  MPEntrySearchNone                 = 0,
  MPEntrySearchUrls                 = (1<<0),
  MPEntrySearchUsernames            = (1<<1),
  MPEntrySearchTitles               = (1<<2),
  MPEntrySearchPasswords            = (1<<3),
  MPEntrySearchNotes                = (1<<4),
  MPEntrySearchAllAttributes        = (1<<5),
  /* The following two flags should be used like enums.
   They are not intended to be used in conjunction with any other flag */
  MPEntrySearchDoublePasswords      = (1<<6),
  MPEntrySearchExpiredEntries       = (1<<7),
  /* All combine-able search flags combined */
  MPEntrySearchAllCombineableFlags  = (MPEntrySearchDoublePasswords |
                                       MPEntrySearchExpiredEntries |
                                       MPEntrySearchNotes |
                                       MPEntrySearchPasswords |
                                       MPEntrySearchTitles |
                                       MPEntrySearchUrls |
                                       MPEntrySearchUsernames |
                                       MPEntrySearchAllAttributes),
  MPEntrySearchSingleFlags          = (MPEntrySearchDoublePasswords | MPEntrySearchExpiredEntries),
  MPEntrySearchAllFlags             = (MPEntrySearchAllCombineableFlags | MPEntrySearchSingleFlags )
};

/* Wrap search criteria to be able to store them */
@interface MPEntrySearchContext : NSObject <NSSecureCoding,NSCopying>

/**
 *  Returns a default search context initialized with sane values.
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
