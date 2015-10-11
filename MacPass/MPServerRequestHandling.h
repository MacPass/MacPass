//
//  MPServerRequestHandler.h
//  MacPass
//
//  Created by Michael Starke on 17.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Protocol for request handling of KeePassHttp request
 */
@protocol MPServerRequestHandling <NSObject>

@required
/**
 *  A unique identifier for the request handler
 *
 *  @return NSString representing the identifier
 */
- (NSString *)identifier;
/**
 *  Formulate a response to the request passed in as Dictionary
 *
 *  @param data An NSDictionary containing the parsed JSON request
 */
- (void)respondTo:(NSDictionary *)data;

@end
