//
//  MPOutlineViewDelegate.h
//  MacPass
//
//  Created by Michael Starke on 21.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

APPKIT_EXTERN NSString *const MPOutlineViewDidChangeGroupSelection;

@class KdbGroup;

@interface MPOutlineViewDelegate : NSObject <NSOutlineViewDelegate>

@property (assign, readonly) KdbGroup *selectedGroup;

@end
