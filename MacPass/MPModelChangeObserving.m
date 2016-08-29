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

@interface MPModelChangeObservingHelper ()
@property (strong) NSMutableSet<NSString *> *observedPaths;
@property (strong) NSMutableSet<NSString *> *matchedPathsCache;
@end

@implementation MPModelChangeObservingHelper

+ (void)willChangeModelKeyPath:(NSString *)keyPath observer:(id<MPModelChangeObserving>)observer {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPWillChangeModelNotification object:observer userInfo:@{ MPModelChangeObservingKeyPathKey : keyPath }];
}

+ (void)didChangeModelKeyPath:(NSString *)keyPath observer:(id<MPModelChangeObserving>)observer {
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDidChangeModelNotification object:observer userInfo:@{ MPModelChangeObservingKeyPathKey : keyPath }];
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath forTarget:(id)target {
  [MPModelChangeObservingHelper willChangeModelKeyPath:keyPath observer:target];
  [target setValue:value forKeyPath:keyPath];
  [MPModelChangeObservingHelper didChangeModelKeyPath:keyPath observer:target];
}

- (void)beginObservingModelChangesForKeyPath:(NSString *)keyPath {
  if(!self.observedPaths) {
    self.observedPaths = [[NSMutableSet alloc] initWithCapacity:3];
  }
  [self.observedPaths addObject:keyPath];
}

- (void)endObservingModelChangesForKeyPath:(NSString *)keyPath {
  [self.observedPaths removeObject:keyPath];
  /* if we have nothing to observer, just clear the cache and exit */
  if(self.observedPaths.count == 0) {
    self.matchedPathsCache = nil;
    return;
  }
  
  NSPredicate *predicat = [NSPredicate predicateWithBlock:^BOOL(id _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
    NSString *cachedPath = evaluatedObject;
    return ![cachedPath hasPrefix:keyPath];
  }];
  [self.matchedPathsCache filterUsingPredicate:predicat];
}

- (BOOL)_isObservingKeyPath:(NSString *)keyPath {
  if([self.matchedPathsCache containsObject:keyPath]) {
    return YES;
  }
  for(NSString *observedKeyPath in self.observedPaths) {
    if([keyPath hasPrefix:observedKeyPath]) {
      if(!self.matchedPathsCache) {
        self.matchedPathsCache = [[NSMutableSet alloc] initWithCapacity:3];
      }
      [self.matchedPathsCache addObject:keyPath];
      return YES;
    }
  }
  return NO;
}

@end
