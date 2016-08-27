//
//  MPModelChangeObserver.m
//  MacPass
//
//  Created by Michael Starke on 26/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import "MPModelChangeObservingHelper.h"
#import "MPModelChangeObserving.h"

NSString *const MPWillChangeModelNotification = @"com.hicknhack.macpass.MPWillChangeModelNotification";
NSString *const MPDidChangreModelNotification = @"com.hicknhack.macpass.MPDidChangeModelNotification";

NSString *const MPModelChangeObservingKeyPathKey = @"MPModelChangeObservingKeyPathKey";

@implementation MPModelChangeObservingHelper

+ (void)willChangeModelKeyPath:(NSString *)keyPath observer:(id<MPModelChangeObserving>)observer {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPWillChangeModelNotification object:observer userInfo:@{ MPModelChangeObservingKeyPathKey : keyPath }];
}

+ (void)didChangeModelKeyPath:(NSString *)keyPath observer:(id<MPModelChangeObserving>)observer {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDidChangreModelNotification object:observer userInfo:@{ MPModelChangeObservingKeyPathKey : keyPath }];

}

@end
