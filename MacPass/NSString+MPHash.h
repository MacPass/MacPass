//
//  NSString+MPHash.h
//  MacPass
//
//  Created by Michael Starke on 05/02/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MPHash)

@property (copy, readonly, nonatomic) NSString *sha1HexDigest;

+ (NSString *)sha1HexDigest:(NSString*)input;

@end
