//
//  MPDocumentQueryService.h
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KPKEntry;

/**
 *  Service to querey  for entries
 */
@interface MPDocumentQueryService : NSObject

+ (MPDocumentQueryService *)sharedService;

- (KPKEntry *)configurationEntry;
- (KPKEntry *)createConfigurationEntry;

@end
