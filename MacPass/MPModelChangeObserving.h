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

FOUNDATION_EXTERN NSString *const MPWillChangeModelNotification;
FOUNDATION_EXTERN NSString *const MPDidChangreModelNotification;

FOUNDATION_EXTERN NSString *const MPModelChangeObservingKeyPathKey;

@required

- (void)willChangeModel;
- (void)didChangeModel;

@end

NS_ASSUME_NONNULL_END