//
//  MPSearchHelper.h
//  MacPass
//
//  Created by Michael Starke on 24/01/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPDocument;

typedef NS_OPTIONS(NSUInteger, MPFilterMode) {
  MPFilterNone            = 0,
  MPFilterUrls            = (1<<0),
  MPFilterUsernames       = (1<<1),
  MPFilterTitles          = (1<<2),
  MPFilterPasswords       = (1<<3),
  MPFilterNotes           = (1<<4),
  MPFilterDoublePasswords = (1<<5)
};

@interface MPEntryFilterHelper : NSObject

+ (NSArray *)entriesInDocument:(MPDocument *)document matching:(NSString *)filter usingFilterMode:(MPFilterMode)mode;
+ (NSArray *)optionsEnabledInMode:(MPFilterMode)mode;
@end
