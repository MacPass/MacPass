//
//  MPDocumentQueryService.h
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPHServer.h"

@class KPKEntry;
@class MPDocument;

/**
 *  Service for querying for resultis withing a request
 *  This shared instance handles creating of config entries,
 *  and abstracts all open documents for the KeePassHttp interface.
 */
@interface MPDocumentQueryService : NSObject <KPHDelegate>

/**
 *  The MPDocument we currently use for our queries
 */
@property (readonly, weak) MPDocument *queryDocument;
/**
 *  The Config entry we did find in our query document
 */
@property (nonatomic, readonly, weak) KPKEntry *configurationEntry;

/**
 *  Access the shared instance of the service
 *
 *  @return shared MPDocumentQueryService instance
 */
+ (MPDocumentQueryService *)sharedService;

@end
