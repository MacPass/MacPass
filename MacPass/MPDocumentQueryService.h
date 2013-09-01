//
//  MPDocumentQueryService.h
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KPKEntry;

@interface MPDocumentQueryService : NSObject

+ (MPDocumentQueryService *)defaultService;

- (KPKEntry *)configurationEntry;
- (KPKEntry *)createConfigurationEntry;

@end
