//
//  MPRequestHandlerService.h
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MPServerRequestHandler;

//FOUNDATION_EXPORT NSString *const MPRequestTypeAssociate;
//FOUNDATION_EXPORT NSString *const MPRequestTypeTestAssociate;
FOUNDATION_EXPORT NSString *const MPRequestTypeGetLogins;
FOUNDATION_EXPORT NSString *const MPRequestTypeGetLoginsCount;
FOUNDATION_EXPORT NSString *const MPRequestTypeGetAllLogins;
FOUNDATION_EXPORT NSString *const MPRequestTypeSetLogin;
FOUNDATION_EXPORT NSString *const MPRequestTypeGeneratePassword;

@interface MPRequestHandlerService : NSObject

+ (id<MPServerRequestHandler>)requestHandler:(NSString *)identifier;

+ (BOOL)validKeyProposal;

@end
