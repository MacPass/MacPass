//
//  DDHotKey+Coding.h
//  MacPass
//
//  Created by Michael Starke on 25/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "DDHotKeyCenter.h"

@interface DDHotKey (Keydata)

+ (instancetype)defaultHotKey;
+ (instancetype)defaultHotKeyWithTask:(DDHotKeyTask)task;
- (NSData *)keyData;
- (instancetype)initWithKeyData:(NSData *)data task:(DDHotKeyTask)task;
- (instancetype)initWithKeyData:(NSData *)data;
@end
