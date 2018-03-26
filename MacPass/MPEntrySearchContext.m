//
//  MPEntrySearch.m
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

#import "MPEntrySearchContext.h"
#import "MPSettingsHelper.h"

@implementation MPEntrySearchContext

+ (BOOL)supportsSecureCoding {
  return YES;
}

+ (instancetype)defaultContext {
  return [[MPEntrySearchContext alloc] init];
}

+ (instancetype)userContext {
  NSData *data = [NSUserDefaults.standardUserDefaults dataForKey:kMPSettingsKeyEntrySearchFilterContext];
  if(data) {
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
  }
  return [self defaultContext];
}

- (instancetype)init {
  self = [self initWithString:nil flags:MPEntrySearchTitles|MPEntrySearchUsernames];
  return self;
}

- (instancetype)initWithString:(NSString *)searchString flags:(MPEntrySearchFlags)flags {
  self = [super init];
  if(self) {
    self.searchFlags = flags;
    self.searchString = searchString;
  }
  return self;

}

#pragma mark NSSecureCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeInteger:self.searchFlags forKey:NSStringFromSelector(@selector(searchFlags))];
  [aCoder encodeObject:self.searchString forKey:NSStringFromSelector(@selector(searchString))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [self init];
  self.searchString = [aDecoder decodeObjectOfClass:NSString.class forKey:NSStringFromSelector(@selector(searchString))];
  self.searchFlags = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(searchFlags))];
  return self;
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
  return [[MPEntrySearchContext alloc] initWithString:self.searchString flags:self.searchFlags];
}

- (void)setSearchFlags:(NSInteger)searchFlags {
  if(_searchFlags != searchFlags) {
    _searchFlags = searchFlags;
    [self _updatePreferences];
  }
}

- (void)setSearchString:(NSString *)searchString {
  if(![_searchString isEqualToString:searchString]) {
    _searchString = [searchString copy];
    [self _updatePreferences];
  }
}

- (void )_updatePreferences {
  NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:self];
  [NSUserDefaults.standardUserDefaults setObject:myData forKey:kMPSettingsKeyEntrySearchFilterContext];
  [NSUserDefaults.standardUserDefaults synchronize];
}
@end
