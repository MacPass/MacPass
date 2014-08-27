//
//  MPEntrySearch.m
//  MacPass
//
//  Created by Michael Starke on 26.06.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPEntrySearchContext.h"

@interface MPEntrySearchContext ()

@property (assign) NSInteger searchFlags;
@property (copy) NSString *searchString;

@end

@implementation MPEntrySearchContext

+ (BOOL)supportsSecureCoding {
  return YES;
}

+ (instancetype)defaultContext {
  
}

- (instancetype)init {
  self = [self initWithString:nil flags:MPEntrySearchNone];
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

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeInteger:self.searchFlags forKey:NSStringFromSelector(@selector(searchFlags))];
  [aCoder encodeObject:self.searchString forKey:NSStringFromSelector(@selector(searchString))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [self init];
  self.searchString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(searchString))];
  self.searchFlags = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(searchFlags))];
  return self;
}

@end
