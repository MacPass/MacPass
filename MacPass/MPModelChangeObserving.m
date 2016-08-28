//
//  MPModelChangeObserver.m
//  MacPass
//
//  Created by Michael Starke on 26/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import "MPModelChangeObserving.h"

NSString *const MPWillChangeModelNotification = @"com.hicknhack.macpass.MPWillChangeModelNotification";
NSString *const MPDidChangeModelNotification = @"com.hicknhack.macpass.MPDidChangeModelNotification";

NSString *const MPModelChangeObservingKeyPathKey = @"MPModelChangeObservingKeyPathKey";

@implementation MPModelChangeObservingHelper

+ (void)willChangeModelKeyPath:(NSString *)keyPath observer:(id<MPModelChangeObserving>)observer {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPWillChangeModelNotification object:observer userInfo:@{ MPModelChangeObservingKeyPathKey : keyPath }];
}

+ (void)didChangeModelKeyPath:(NSString *)keyPath observer:(id<MPModelChangeObserving>)observer {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDidChangeModelNotification object:observer userInfo:@{ MPModelChangeObservingKeyPathKey : keyPath }];
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath forTarget:(id)target {
  [target setValue:value forKeyPath:keyPath];
}

@end
