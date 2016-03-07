//
//  MPEntryProxy.h
//  MacPass
//
//  Created by Michael Starke on 07/03/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Proxies the display of an entry to enable discardable changes to the entry
 */

NS_ASSUME_NONNULL_BEGIN

@class KPKEntry;

@interface MPEntryProxy : NSProxy

- (instancetype)initWithEntry:(KPKEntry *)entry;

@end

NS_ASSUME_NONNULL_END
