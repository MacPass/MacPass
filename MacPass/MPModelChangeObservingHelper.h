//
//  MPModelChangeObserver.h
//  MacPass
//
//  Created by Michael Starke on 26/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class is usefull to implement modelchangeobserving by just forwarding the protocoll calls to the helper
 */

@protocol MPModelChangeObserving;

@interface MPModelChangeObservingHelper : NSObject

+ (void)willChangeModelKeyPath:(NSString *)keyPath observer:(id<MPModelChangeObserving>)observer;
+ (void)didChangeModelKeyPath:(NSString *)keyPath observer:(id<MPModelChangeObserving>)observer;

@end
