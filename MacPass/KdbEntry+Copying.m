//
//  KdbEntry+Copying.m
//  MacPass
//
//  Created by Michael Starke on 18.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbEntry+Copying.h"

@implementation KdbEntry (Copying)

- (id)copyWithZone:(NSZone *)zone {
  [self doesNotRecognizeSelector:_cmd];
  return  nil;
}


@end
