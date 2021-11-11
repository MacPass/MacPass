//
//  MPOpenURLHandler.h
//  MacPass
//
//  Created by Michael Starke on 11.11.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPOpenURLHandler : NSObject

@property (class, strong, readonly) MPOpenURLHandler *sharedHandler;
- (instancetype)init NS_UNAVAILABLE;

- (void)openURL:(NSString *)url;
- (BOOL)supportsPrivateBrowsingForBundleId:(NSString *)bundleId;

@end

NS_ASSUME_NONNULL_END
