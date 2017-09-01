//
//  MPPasswordInputController.h
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

@class KPKCompositeKey;

@interface MPPasswordInputController : MPViewController

typedef BOOL (^passwordInputCompletionBlock)(NSString *password, NSURL *keyURL, BOOL didCancel, NSError *__autoreleasing*error);

- (void)requestPasswordWithCompletionHandler:(passwordInputCompletionBlock)completionHandler;
- (void)requestPasswordWithMessage:(NSString *)message cancelLabel:(NSString *)cancelLabel completionHandler:(passwordInputCompletionBlock)completionHandler;


@end
