//
//  MPConnection.h
//  MacPass
//
//  Created by Michael Starke on 16.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "HTTPConnection.h"

/**
 *  Default Connection to handle the KeepassHttp POST requests. The Connection doesn't do anything,
 *  besides using the MPRequestHandlerService to handle any request from KeePassHttp and send's back the replies
 */
@interface MPConnection : HTTPConnection

@end
