//
//  MPModelChangeObserving.h
//  MacPass
//
//  Created by Michael Starke on 26/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MPModelChangeObserving <NSObject>

/* A class conforming to the protocoll will shoudl always fire the appropriate notifications listes below
 
 You need to overwrite setValue:forKeyPath in a conforming class. For convinience you can just call the helper and lett it do the job
 
 */
FOUNDATION_EXTERN NSString *const MPWillChangeModelNotification;
FOUNDATION_EXTERN NSString *const MPDidChangeModelNotification;

FOUNDATION_EXTERN NSString *const MPModelChangeObservingKeyPathKey;

@required
- (void)beginObservingModelChangesForKeyPath:(NSString *)keyPath;
- (void)endObservingModelChangesForKeyPath:(NSString *)keyPath;
@end

/* Use this helper to fire the right notifications. You can hold an instance to help in you implementation of setValue:forKeyPath and observerModelChangesForKeyPath: */
@interface MPModelChangeObservingHelper : NSObject

+ (void)willChangeModelKeyPath:(NSString *)keyPath observer:(id<MPModelChangeObserving>)observer;
+ (void)didChangeModelKeyPath:(NSString *)keyPath observer:(id<MPModelChangeObserving>)observer;
- (void)beginObservingModelChangesForKeyPath:(NSString *)keyPath;
- (void)endObservingModelChangesForKeyPath:(NSString *)keyPath;
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath forTarget:(id)target;

@end

NS_ASSUME_NONNULL_END