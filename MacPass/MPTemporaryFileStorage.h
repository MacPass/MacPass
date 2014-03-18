//
//  MPTemporaryFileStorage.h
//  MacPass
//
//  Created by Michael Starke on 18/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  Instance to handle a temporary file storage. Quicklook support uses this as a means to vent attachments to the system
 *  After using the file, the storage is removed.
 */

@class KPKBinary;

@interface MPTemporaryFileStorage : NSObject

- (instancetype)initWithBinary:(KPKBinary *)binary;

- (void)quicklook;

@end
