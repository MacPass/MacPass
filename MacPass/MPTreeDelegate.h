//
//  MPTreeDelegate.h
//  MacPass
//
//  Created by Michael Starke on 01/09/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KeePassKit/KeePassKit.h"

@class MPDocument;

@interface MPTreeDelegate : NSObject <KPKTreeDelegate>

- (instancetype)initWithDocument:(MPDocument *)document;

@end
