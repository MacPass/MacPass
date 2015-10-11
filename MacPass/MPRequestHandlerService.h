//
//  MPRequestHandlerService.h
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MPServerRequestHandling;

FOUNDATION_EXPORT NSString *const MPRequestTypeGetLogins;
FOUNDATION_EXPORT NSString *const MPRequestTypeGetLoginsCount;
FOUNDATION_EXPORT NSString *const MPRequestTypeGetAllLogins;
FOUNDATION_EXPORT NSString *const MPRequestTypeSetLogin;
FOUNDATION_EXPORT NSString *const MPRequestTypeGeneratePassword;

/**
 *  Service class to be called for getting specific request handler for individual request
 *  The service is identified by a string
 */
@interface MPRequestHandlerService : NSObject

+ (id<MPServerRequestHandling>)requestHandler:(NSString *)identifier;

+ (BOOL)validKeyProposal;

@end
