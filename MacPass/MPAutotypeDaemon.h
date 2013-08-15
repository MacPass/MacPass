//
//  MPAutotypeDaemon.h
//  MacPass
//
//  Created by Michael Starke on 15.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPAutotypeDaemon : NSObject

- (void)processEvent;
- (void)sendKeystrokes;

@end
