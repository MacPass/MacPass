//
//  MPConnection.m
//  MacPass
//
//  Created by Michael Starke on 16.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPConnection.h"
#import "HTTPMessage.h"

NSString *const MPRequestTypeAssociate        = @"associate";
NSString *const MPRequestTypeTestAssociate    = @"test-associate";
NSString *const MPRequestTypeGetLogins        = @"get-logins";
NSString *const MPRequestTypeGetLoginsCount   = @"get-logins-count";
NSString *const MPRequestTypeGetAllLogins     = @"get-all-logins";
NSString *const MPRequestTypeSetLogin         = @"set-login";
NSString *const MPRequestTypeGeneratePassword = @"generate-password";

NSString *const MPRequestTypeKey = @"RequestType";

@implementation MPConnection

+ (NSArray *)requestHander {
  

}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
  // Override me to support methods such as POST.
  //
  // Things you may want to consider:
  // - Does the given path represent a resource that is designed to accept this method?
  // - If accepting an upload, is the size of the data being uploaded too big?
  //   To do this you can check the requestContentLength variable.
  //
  // For more information, you can always access the HTTPMessage request variable.
  //
  // You should fall through with a call to [super supportsMethod:method atPath:path]
  //
  // See also: expectsRequestBodyFromMethod:atPath:
  
  if([method isEqualToString:@"POST"]) {
    return YES;
  }
  return [super supportsMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
  
  NSError *error = nil;
  id obj = [NSJSONSerialization JSONObjectWithData:[request body] options:0 error:&error];
  if(error) {
    NSLog(@"Error while parsing request:%@", [error localizedDescription]);
  }
  if([obj isKindOfClass:[NSDictionary class]]) {
    NSDictionary *requestDict = obj;
    [self _parseRequest:requestDict];
  }
  else {
    NSLog(@"Wrong Request format. Unable to use JSON data");
  }
  return nil;
}

- (void)processBodyData:(NSData *)postDataChunk {
  [request appendData:postDataChunk];
}


- (void)_parseRequest:(NSDictionary *)aRequest {
  NSString *requestType = aRequest[MPRequestTypeKey];
  if(!requestType) {
    NSLog(@"Malformed Request. Missing request type");
  }
  NSLog(@"%@", requestType);
  if([requestType isEqualToString:MPRequestTypeAssociate]) {
    return;
  }
  if([requestType isEqualToString:MPRequestTypeGeneratePassword]) {
    return;
  }
}

@end
