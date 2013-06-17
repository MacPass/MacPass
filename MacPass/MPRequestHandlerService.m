//
//  MPRequestHandlerService.m
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPRequestHandlerService.h"
#import "MPServerRequestHandler.h"
#import "MPAssociateRequestHandler.h"
#import "MPTestAssociateRequestHandler.h"

//NSString *const MPRequestTypeAssociate        = @"associate";
//NSString *const MPRequestTypeTestAssociate    = @"test-associate";
NSString *const MPRequestTypeGetLogins        = @"get-logins";
NSString *const MPRequestTypeGetLoginsCount   = @"get-logins-count";
NSString *const MPRequestTypeGetAllLogins     = @"get-all-logins";
NSString *const MPRequestTypeSetLogin         = @"set-login";
NSString *const MPRequestTypeGeneratePassword = @"generate-password";

@implementation MPRequestHandlerService

+ (id<MPServerRequestHandler>)requestHandler:(NSString *)identifier {
  return [self requestHander][identifier];
}

+ (NSDictionary *)requestHander {
  static NSDictionary *requestHandler;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    requestHandler = [[self _setupHandlerDictionary] retain];
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
  [associateHandler release];
  [testAssociateHandler release];
  return handlerDict;
}

+ (BOOL)validKeyProposal {
  return NO;
}

@end
