//
//  MPDocument.h
//  MacPass
//
//  Created by Michael Starke on 21.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

APPKIT_EXTERN NSString *const MPDidLoadDataBaseNotification;

@interface MPDatabaseDocument : NSObject

- (id)initWithFile:(NSURL *)file password:(NSString *)password keyfile:(NSURL *)key;

@end
