//
//  MPRequestHandlerService.m
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPRequestHandlerService.h"
#import "MPServerRequestHandling.h"
#import "MPAssociateRequestHandler.h"
#import "MPTestAssociateRequestHandler.h"

NSString *const MPRequestTypeGetLogins        = @"get-logins";
NSString *const MPRequestTypeGetLoginsCount   = @"get-logins-count";
NSString *const MPRequestTypeGetAllLogins     = @"get-all-logins";
NSString *const MPRequestTypeSetLogin         = @"set-login";
NSString *const MPRequestTypeGeneratePassword = @"generate-password";

@implementation MPRequestHandlerService

+ (id<MPServerRequestHandling>)requestHandler:(NSString *)identifier {
  return [self requestHandler][identifier];
}

+ (NSDictionary *)requestHandler {
  static NSDictionary *requestHandler;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    requestHandler = [self _setupHandlerDictionary];
  });
  return requestHandler;
}

+ (NSDictionary *)_setupHandlerDictionary {
  MPAssociateRequestHandler *associateHandler = [[MPAssociateRequestHandler alloc] init];
  MPTestAssociateRequestHandler *testAssociateHandler = [[MPTestAssociateRequestHandler alloc] init];
  NSDictionary *handlerDict = @{
                                [associateHandler identifier] : associateHandler,
                                [testAssociateHandler identifier] : testAssociateHandler
                                };
  return handlerDict;
}

+ (BOOL)validKeyProposal {
  return NO;
}

@end
